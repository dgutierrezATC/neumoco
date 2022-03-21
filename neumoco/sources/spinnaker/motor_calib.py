"""
****************************************************************************
*********************************** Test ***********************************
****************************************************************************
******************* @Program by Daniel Gutierrez-Galan *********************
****************************************************************************
"""

#--- Importing  libraries ---#
import spynnaker8 as p
import pylab
import numpy as np
import serial
import time
import matplotlib.pyplot as plt
import pyNN.utility.plotting as plot

connected_chip_details = {
    "spinnaker_link_id": 1,
}

def get_updated_params(params):
    params.update(connected_chip_details)
    return params

#--- simulation setup ---#
p.setup(timestep=1.0, min_delay=1.0, max_delay=144., time_scale_factor=1)


#-- Config parameters --#
t = 10000   #time of simulation in ms
ndvs_neurons = 128*128
num_positions = 512

#--- Neuron type parameters ---#
cell_params_lif = {'cm': 0.25,
                   'i_offset': 0.0,
                   'tau_m': 20.0,
                   'tau_refrac': 2.0,
                   'tau_syn_E': 5.0,
                   'tau_syn_I': 5.0,
                   'v_reset': -68.0,
                   'v_rest': -65.0,
                   'v_thresh': -50.0
                   }

retina_pop = p.Population(
    16, p.external_devices.ExternalFPGARetinaDevice, get_updated_params({
        'retina_key': 0xfefe,
        'mode': p.external_devices.ExternalFPGARetinaDevice.MODE_128,
        'polarity': p.external_devices.ExternalFPGARetinaDevice.DOWN_POLARITY}),
    label='retina_pop')


	


listSpikes = [[] for i in range(num_positions)]
listSpikes[0].append(5000)
ssa_times = None
ssa_times = {'spike_times': listSpikes}

motor_pop = p.Population(num_positions, p.SpikeSourceArray, ssa_times, label='motor_pop')

out_pop = p.Population(16, p.IF_curr_exp, cell_params_lif, label='out_pop')

p.Projection(retina_pop, out_pop, p.OneToOneConnector(), synapse_type=p.StaticSynapse(weight=0.7, delay=1.0))

out_pop.record(["spikes", "v"])

p.external_devices.activate_live_output_to(motor_pop, retina_pop)

#---runing simulation ---#
p.run(t)

neo = out_pop.get_data(variables=["spikes", "v"])
spikes = neo.segments[0].spiketrains
print spikes
v = neo.segments[0].filter(name='v')[0]
print v

#--- Finish simulation ---#
p.end()

#--- Variables for saving spikes ---#




plot.Figure(
    # plot voltage for first ([0]) neuron
    plot.Panel(v, ylabel="Membrane potential (mV)",
               data_labels=[out_pop.label], yticks=True, xlim=(0, t)),
    # plot spikes (or in this case spike)
    plot.Panel(spikes, yticks=True, markersize=5, xlim=(0, t)),

    title="Simple Example",
    annotations="Simulated with {}".format(p.name())
)
plt.show()

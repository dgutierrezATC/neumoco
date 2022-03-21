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
    "spinnaker_link_id": 0,
}

def get_updated_params(params):
    params.update(connected_chip_details)
    return params

#--- simulation setup ---#
p.setup(timestep=1.0, min_delay=1.0, max_delay=144., time_scale_factor=1)


#-- Config parameters --#
t = 2000   #time of simulation in ms
ndvs_neurons = 128*128

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
    ndvs_neurons, ExternalDevices.ExternalFPGARetinaDevice, get_updated_params({
        'retina_key': 0x200,
        'mode': ExternalDevices.ExternalFPGARetinaDevice.MODE_128,
        'polarity': ExternalDevices.ExternalFPGARetinaDevice.DOWN_POLARITY}),
    label='External_retina')

out_pop = p.Population(ndvs_neurons, p.IF_curr_exp, cell_params_lif, label='out_layer')

p.Projection(retina_pop, out_pop, p.OneToOneConnector(), synapse_type=p.StaticSynapse(weight=0.7, delay=1.0))

out_pop.record(["spikes", "v"])

#p.external_devices.activate_live_output_to(out_pop, retina_pop)

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

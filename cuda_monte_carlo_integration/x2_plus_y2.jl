using CUDA
using Statistics

#############################################################
# KERNEL TO COMPUTE x^2 + y^2                               #
#############################################################

function gpu_fxy(x, y, fxy)
    index = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    stride = blockDim().x * gridDim().x

    for i ∈ index:stride:length(x)
        @inbounds fxy[i] = x[i]^2 + y[i]^2
    end

    return nothing
end

#############################################################
# NUMBER OF ITERATIONS                                      #
#############################################################

N = 65_536

#############################################################
# ARRAYS TO HOLD RANDOM VALUES AND THE FUNCTION COMPUTED    #
# AT THOSE VALUES                                           #
#############################################################

x_d = CUDA.rand(N)
y_d = CUDA.rand(N)
fxy_d = CUDA.zeros(N)

#############################################################
# RUN KERNEL ON THE GPU                                     #
#############################################################

max_threads = CUDA.attribute(device(), CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)
num_blocks = ceil(Int32, N/max_threads)
@cuda threads=max_threads blocks=num_blocks gpu_fxy(x_d, y_d, fxy_d)

#############################################################
# RUN KERNEL ON THE GPU                                     #
#############################################################

result = mean(Array(fxy_d))
println(result)

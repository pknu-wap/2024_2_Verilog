import random
def get_random_16bit(): print("{:0>16b}".format(random.randrange(0, 2 ** 16 - 1)))
get_random_16bit()

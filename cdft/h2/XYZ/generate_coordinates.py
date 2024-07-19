from ase import Atoms
from ase.io import write
import numpy as np

def main():
	a = np.arange(0.5, 1.55, 0.05)
	b = np.arange(5, 10.5, 0.5)
	cell = [15.]*3
	distances = np.concatenate((a,b))
	for dist in distances:
		sys = Atoms('H2', positions=[[0, 0, 0], [0, 0, dist]], cell=cell)
		sys.center()
		write('h2-dist-{:.2f}.xyz'.format(dist), sys)
		fragment = Atoms('H', positions=[sys.positions[0]], cell=cell)
		write('h2-dist-{:.2f}-frag-1.xyz'.format(dist), fragment)
		fragment = Atoms('H', positions=[sys.positions[-1]], cell=cell)
		write('h2-dist-{:.2f}-frag-2.xyz'.format(dist), fragment)

if __name__ == '__main__':
	main()

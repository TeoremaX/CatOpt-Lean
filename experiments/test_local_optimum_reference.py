import random
import unittest
from local_optimum_reference import cost, reverse_segment, check_local_optimum, four_edge_delta

class LocalOptimalityTests(unittest.TestCase):
    def test_square(self):
        d = [[0 if i == j else 1 if (i-j) % 4 in (1,3) else 2 for j in range(4)] for i in range(4)]
        self.assertEqual(cost([0,2,1,3],d),6)
        self.assertEqual(cost([0,1,2,3],d),4)
        self.assertFalse(check_local_optimum([0,2,1,3],d))
        self.assertTrue(check_local_optimum([0,1,2,3],d))

    def test_permutations_preserved(self):
        for n in range(2,8):
            p=list(range(n))
            for lo in range(n):
                for hi in range(lo,n):
                    q=reverse_segment(p,lo,hi)
                    self.assertEqual(sorted(q),p)
                    self.assertEqual(reverse_segment(q,lo,hi),p)

    def test_four_edge_delta_only_symmetric(self):
        rng=random.Random(37)
        for n in range(3,11):
            for _ in range(20):
                m=[[0]*n for _ in range(n)]
                for i in range(n):
                    for j in range(i+1,n):
                        m[i][j] = m[j][i] = rng.randrange(1,200)
                p=list(range(n));rng.shuffle(p)
                old=cost(p,m)
                for lo in range(1,n):
                    for hi in range(lo,n):
                        self.assertEqual(cost(reverse_segment(p,lo,hi),m)-old,
                                         four_edge_delta(p,m,lo,hi))

    def test_directed_counterexample(self):
        m=[[0]*4 for _ in range(4)]
        m[1][2]=1
        m[2][1]=100
        p=[0,1,2,3]
        actual = cost(reverse_segment(p,1,2),m)-cost(p,m)
        predicted = four_edge_delta(p,m,1,2)
        self.assertEqual(actual,99)
        self.assertEqual(predicted,0)
        self.assertNotEqual(actual,predicted)

if __name__ == '__main__':
    unittest.main()

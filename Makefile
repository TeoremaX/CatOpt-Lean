.PHONY: lean test demo benchmark check
lean:
	lake build

test:
	python3 -m unittest discover -s experiments -p 'test_*.py' -v

demo:
	lake exe catopt-demo

benchmark:
	python3 experiments/run_benchmark.py --runs 15 --budget 5000

check:
	bash scripts/check.sh

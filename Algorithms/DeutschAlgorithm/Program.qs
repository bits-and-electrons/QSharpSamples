namespace DeutschAlgorithm {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    @EntryPoint()
    operation RunAlgorithm() : Unit {
        mutable result1 = ConstantTestCase();
        Fact(result1 == true, $"ConstantTestCase ==> {result1}");
        Message($"ConstantTestCase ==> {result1}");

        mutable result2 = BalancedTestCase();
        Fact(result2 == false, $"BalancedTestCase ==> {result2}");
        Message($"BalancedTestCase ==> {result2}");
    }

    operation ConstantTestCase () : Bool {
        return DeutschsAlgorithm(UF(SampleConstantFunction));
    }

    operation BalancedTestCase () : Bool {
        return DeutschsAlgorithm(UF(SampleBalancedFunction));
    }

	operation SampleConstantFunction(n : Int) : Int {
		return 1;
	}

	operation SampleBalancedFunction(n : Int) : Int {
		return n % 2;
	}

    operation DeutschsAlgorithm (uf : (Qubit[] => Unit)) : Bool {
		mutable result = Zero;

		use qubits = Qubit[2] {
			Set (qubits[1], One);
			ApplyToEach(H, qubits);

			uf(qubits);
			H(qubits[0]);

			set result = M(qubits[0]);
			ResetAll(qubits);
		}

		return result == Zero;
	}

	operation UF_ (F : (Int => Int), qubits : Qubit[]) : Unit {
		let x = qubits[0];
		let y = qubits[1];

		for index in 0..1 {
			if (F(index) == 1) {
				let oper = (ControlledOnInt(index, ApplyToEachCA(X, _)));
				oper([x], [y]);
			}
		}
	}

	operation UF (F : (Int => Int)) : (Qubit[] => Unit) {
		return UF_ (F , _);
	}

    operation Set (qubit: Qubit, desired: Result) : Unit {
        let current = M(qubit);

        if (desired != current) {
            X(qubit);
        }
    }
}

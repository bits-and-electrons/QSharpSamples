namespace AdderCircuit {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    
    @EntryPoint()
    operation StartCircuit() : Unit {
        mutable result1 = AdderCircuit(2, 3);
        Message($"2 + 3 = {result1}");

        mutable result2 = AdderCircuit(5, 6);
        Message($"5 + 6 = {result2}");

        mutable result3 = AdderCircuit(8, 9);
        Message($"8 + 9 = {result3}");
    }

    operation AdderCircuit (a_Int: Int, b_Int: Int) : Int  {
	    mutable result = -1;

        use b_Qubit = Qubit[BitSizeI(a_Int + b_Int)] {
			ToQubitArrayI(b_Int, b_Qubit);

			Adder(b_Qubit, a_Int);

			set result = MeasureInteger(LittleEndian(b_Qubit));
			ResetAll(b_Qubit);
		}

		return result;
    }

	operation Adder (b_Qubit: Qubit[], a_Int: Int) : Unit {
		body(...) {
			use a_Qubit = Qubit[BitSizeI(a_Int)] {
				ToQubitArrayI(a_Int, a_Qubit);

				QFT_(b_Qubit);
				ADD(a_Qubit, b_Qubit);
				Adjoint QFT_(b_Qubit);

				Adjoint ToQubitArrayI(a_Int, a_Qubit);
			}
		}

		adjoint auto; 
        controlled auto;
		adjoint controlled auto;
	}

	operation ADD (a_Qubit: Qubit[], b_Qubit: Qubit[]) : Unit {
		body(...) {
			let a_Bitcount = Length(a_Qubit);
			let b_Bitcount = Length(b_Qubit);

			for index1 in 0 .. (b_Bitcount - 1) {
				for index2 in 0 .. (b_Bitcount - index1 - 1) {
					if (b_Bitcount - index1 - index2 - 1 < a_Bitcount) {
						(Controlled PhaseShift)([a_Qubit[b_Bitcount - index1 - index2 - 1]], (b_Qubit[b_Bitcount - index1 - 1], IntAsDouble(index2 + 1)));
					}
				}
			}

			// (Controlled PhaseShift)([a_Qubit[3]], (b_Qubit[3], 1.00));
			// (Controlled PhaseShift)([a_Qubit[2]], (b_Qubit[3], 2.00));
			// (Controlled PhaseShift)([a_Qubit[1]], (b_Qubit[3], 3.00));
			// (Controlled PhaseShift)([a_Qubit[0]], (b_Qubit[3], 4.00));

			// (Controlled PhaseShift)([a_Qubit[2]], (b_Qubit[2], 1.00));
			// (Controlled PhaseShift)([a_Qubit[1]], (b_Qubit[2], 2.00));
			// (Controlled PhaseShift)([a_Qubit[0]], (b_Qubit[2], 3.00));
                
			// (Controlled PhaseShift)([a_Qubit[1]], (b_Qubit[1], 1.00));
			// (Controlled PhaseShift)([a_Qubit[0]], (b_Qubit[1], 2.00));
                
			// (Controlled PhaseShift)([a_Qubit[0]], (b_Qubit[0], 1.00));
		}
		
		adjoint auto; 
        controlled auto;
		adjoint controlled auto;
	}

	operation QFT_ (qubits: Qubit[]) : Unit {
		body(...) {
			mutable bitCount = Length(qubits);

			for index1 in 0 .. (bitCount - 1) {
				H(qubits[bitCount - index1 - 1]);

				for index2 in 0 .. (bitCount - index1 - 2) {
					(Controlled PhaseShift)([qubits[bitCount - index1 - index2 - 2]], (qubits[bitCount - index1 - 1], IntAsDouble(index2 + 2)));
				}
			}

			// H(qubits[3]);
			// (Controlled PhaseShift)([qubits[2]], (qubits[3], 2.00));
			// (Controlled PhaseShift)([qubits[1]], (qubits[3], 3.00));
			// (Controlled PhaseShift)([qubits[0]], (qubits[3], 4.00));

			// H(qubits[2]);
			// (Controlled PhaseShift)([qubits[1]], (qubits[2], 2.00));
			// (Controlled PhaseShift)([qubits[0]], (qubits[2], 3.00));

			// H(qubits[1]);
			// (Controlled PhaseShift)([qubits[0]], (qubits[1], 2.00));

			// H(qubits[0]);
		}

		adjoint auto; 
        controlled auto;
		adjoint controlled auto;
	}

	operation PhaseShift (qubit: Qubit, power: Double) : Unit
    {
		body(...) {
			let thetha = (2.00 * PI()) / PowD(2.00, power);
			R1(thetha, qubit);
		}
        
		adjoint auto; 
        controlled auto;
		adjoint controlled auto;
    }

	operation ToQubitArrayI (value: Int, qubits: Qubit[]) : Unit
	{
		body(...) {
			ApplyXorInPlace(value, LittleEndian(qubits));
		}
        
		adjoint auto; 
        controlled auto;
		adjoint controlled auto;
	}
}

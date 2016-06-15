/*
 * estimation.h
 *
 *  Created on: 13/04/2016
 *      Author: Milder
 */

#ifndef ESTIMATION_ESTIMATION_H_
#define ESTIMATION_ESTIMATION_H_

#include "../model/model.h"
#include "../model/twopl.h"
#include "../util/matrix.h"
#include "../util/itemparameter.h"
#include "../util/quadraturepoints.h"
#include "../util/initial_values.h"
#include "estep.h"
#include "mstep.h"
#include <map>
#include <cmath>

namespace irtpp {

extern model m;
/**
 * Dimension of the data
 * */
extern short d;
/**
 * Number of items
 * */
extern int p;
/**
 * Number of response patterns
 * */
extern int s;

/**
 * Number of examinees
 * */
extern int N;

/**
 * Vector of parameters
 * */
extern std::vector<item_parameter> zeta;

/**
 * Y , s x p, matrix of pattern responses.
 *
 * where s is the number of patterns s <= N (N, number of examinees)
 * p is the number of items
 * */
extern matrix<char> Y;

/**
 * Dichotomized matrix
 * */
extern std::vector<matrix<int> > X;

/**
 * nl, frequencies of each pattern allocated in Y
 * */
extern std::vector<int> nl;

// Latent trait vectors
extern matrix<double> theta;

// Weights
extern std::vector<double> w;

extern const int MAX_NUMBER_OF_QUADRATURE_POINTS;



/*
 * Class to run the estimation process
 *
 * The main method is EMAlgorithm
 * */
class estimation {
	private:
		const int MAX_ITERATIONS = 500;

		short iterations;

		double convergence_difference;

		/**
		 * vector to allocate the number of categories of each item
		 * */
		std::vector<int> categories_item;

	public:
		estimation();

		/**
		 * This constructor receives a specific model to use
		 * and a matrix containing the answers of examinees
		 *
		 * Optional parameters are number of iterations
		 * and convergence difference (between an iteration and before)
		 *
		 * If convergence difference is not defined its default value is 0.0001
		 * If number of iterations is not defined its default value is -1
		 * 		which means that the EMalgorithm does not take into account
		 * 		iterations, it finishes when the convergence difference is reached
		 *
		 *
		 *
		 * Then it builds the matrix of pattern responses and its frequency
		 * */
		estimation(int, matrix<char>&, short, double);


		/**
		 * Constructor of multidimensional case
		 *
		 * A vector that stores the number of items that each dimension has
		 * */
		estimation(int, matrix<char>&, short, double, std::vector<int>&);

		virtual ~estimation();

		void initial_values();
		/*
		 * Runs the EMAlgorithm to find out the parameters
		 * depending on what is the model used
		 * */
		void EMAlgortihm();

		/**
		 * Prints the results
		 * Values for alphas and d's
		 * */
		void print_results();

		/**
		 * Prints the results to a specific output stream, including time elapsed
		 * */
		void print_results(std::ofstream &, double);
};

} /* namespace irtpp */

#endif /* ESTIMATION_ESTIMATION_H_ */

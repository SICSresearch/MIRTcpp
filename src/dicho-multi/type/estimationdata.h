/*
 * estimationdata.h
 *
 *  Created on: 20/06/2016
 *      Author: Milder
 */

#ifndef DICHOMULTI_UTIL_ESTIMATIONDATA_H_
#define DICHOMULTI_UTIL_ESTIMATIONDATA_H_
#include <vector>
#include <set>
#include "../../util/matrix.h"
#include "../../util/constants.h"

#include <dlib/optimization.h>

#include <algorithm>

#include "../../dicho-multi/model/model.h"

namespace irtpp {

namespace dichomulti {

typedef dlib::matrix<double,0,1> item_parameter; /**< data type from dlib library*/

/**
 * estimation_data class contains all the information needed to execute the EM estimation in
 * dichotomous model
 */
class estimation_data {
public:
	matrix<char> *dataset; /**< Matrix of answers*/
	matrix<int> correct; /**< Matrix that contains what items have been answered correctly for each response pattern*/
	int d; /**< Dimension*/
	matrix<char> Y; /**< Matrix of response patterns*/
	std::vector<int> nl; /**< Frequencies of each response pattern*/
	int N; /**< Number of examines*/
	int s; /**< Number of response patterns*/
	int p; /**< Number of items*/
	int G; /**< Number of quadrature points*/
	matrix<double> theta; /**< Latent traits vectors*/
	std::vector<double> w; /**< Weights*/
	matrix<double> r; /**< Matrix r*/
	matrix<double> P; /**< Probability matrix P, P_gi means the probability that an individual has selected the correct answer*/
	matrix<double> pi; /**< Matrix pi*/
	std::vector<double> f; /**< Vector f (Number of individuals in group g)*/
	std::set<int> pinned_items; /**< Pinned items (won't be estimated)*/
	std::vector<item_parameter> zeta[ACCELERATION_PERIOD]; /**< Vector of zeta item parameters*/
	model m; /**< Model to use*/

	//Frequencies
	std::map<std::vector<char>, std::vector<int> > frequencies;

	//Latent traits
	matrix<double> latent_traits;

	estimation_data(int);

	/**
	 * Default constructor for estimation_data. Is not working, don't use.
	 */
	estimation_data();

	/**
	 * Default destructor for estimation_data. Is not working, don't use.
	 */
	virtual ~estimation_data();
};

}

} /* namespace irtpp */

#endif /* UTIL_ESTIMATIONDATA_H_ */

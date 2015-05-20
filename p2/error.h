/*
    class Error provides a means to unify error messages

    If students print error messages using class Error then all their
    error messages will be identical to my error messages and thus it 
    will be much easier to test and grade the assignments.

    To issue an error message, call the following static function 

        static void error(Error_type type, 
                          string s1 = "", 
                          string s2 = "", 
                          string s3 = "");

    Static functions can be called w/o instantiating an Error object:

       Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, name);

    Error_type is an enumerated type.  When you need to issue an error
    message look through the elements of Error_type to find the error
    message that matches what you want to issue.

    Each error message interprets the arguments (s1, s2, s3) differently.
    Most don't use all of them, some don't use any.  You need to look in 
    error.cpp to see which argument is used for a particular message.

    For example, consider the error previously declared variable.  This
    error assumes that s1 contains the textual name of the variable that
    has been previously declared.

        case PREVIOUSLY_DECLARED_VARIABLE:
            error_header();
            cerr << "Variable '"<< s1 << "'" << " previously declared." 
                 << endl;
            break;
*/

#ifndef ERROR_H
#define ERROR_H

#include <string>
using namespace std;

class Error
{
    public:
        enum Error_type {
                          // in future phases of the assignment, many other errors will be defined here
                          ILLEGAL_TOKEN,
                          PARSE_ERROR,
                          UNDEFINED_ERROR
                         };

        static void error(Error_type type, 
                          string s1 = "", 
                          string s2 = "", 
                          string s3 = "");

        static void starting_execution() {m_runtime = true;}

        static int num_errors() {return m_num_errors;}
        static bool runtime() {return m_runtime;}

    protected:
        static bool m_runtime;
        static int m_num_errors;
        static void error_header();
};

#endif // #ifndef ERROR_H

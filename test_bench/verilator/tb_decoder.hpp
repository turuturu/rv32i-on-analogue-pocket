#include "Valu.h"

class ValuDecoder : public Valu {
   public:
    ValuDecoder() : Valu() {}
    ~ValuDecoder() {}

    void exec(const int &_instr);
};


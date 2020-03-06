# --------------------------------------------------------------------
# --   *****************************
# --   *   Trenz Electronic GmbH   *
# --   *   Holzweg 19A             *
# --   *   32257 Bünde             *
# --   *   Germany                 *
# --   *****************************
# --------------------------------------------------------------------
# -- $Author: Hartfiel, John $
# -- $Email: j.hartfiel@trenz-electronic.de $
# --------------------------------------------------------------------
# -- Change History:
# ------------------------------------------
# -- $Date: 2016/02/03 | $Author: Hartfiel, John
# -- - initial release
# ------------------------------------------
# -- $Date: 2017/02/02  | $Author: Hartfiel, John
# -- - miscellaneous
# ------------------------------------------
# -- $Date:  2017/09/04  | $Author: Hartfiel, John
# -- - add new document history style
# ------------------------------------------
# -- $Date: 0000/00/00  | $Author:
# -- - 
# --------------------------------------------------------------------
# --------------------------------------------------------------------
namespace eval ::TE {
  namespace eval ENV {
    # -----------------------------------------------------------------------------------------------------------------------------------------
    # initial vivado lib paths
    # -----------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #--set_path_boarddef:  
    proc set_path_boarddef {} {
      TE::UTILS::te_msg TE_INIT-69 INFO "Set Board Definition path: $TE::BOARDDEF_PATH"
      set_param board.repoPaths $TE::BOARDDEF_PATH
    }
    #--------------------------------
    #--set_path_boarddef: 
    proc set_path_ip {} {
      TE::UTILS::te_msg TE_INIT-70 INFO "Set IP path : $TE::IP_PATH"
      set_property IP_REPO_PATHS $TE::IP_PATH [current_fileset]
      ::update_ip_catalog
    }
    # -----------------------------------------------------------------------------------------------------------------------------------------
    # finished vivado lib paths
    # -----------------------------------------------------------------------------------------------------------------------------------------
  
  
  
  # -----------------------------------------------------------------------------------------------------------------------------------------

	}
  puts "INFO:(TE) Load environment script finished"
}



From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 0/2] Series short description
Date: Mon, 01 Aug 2011 17:10:19 -0400
Message-ID: <20110801210642.11940.49764.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A little bit of housekeeping as I'm leaving HP and my email address will
be going away at the end of this week.  For those of you who need to
contact me directly please use the address in the CC line above (and
mentioned in the patches below).  The first patch is a pretty straight
forward update of the MAINTAINERS file, the second patch updates my
email in the various source files.

---

Paul Moore (2):
      doc: Update the MAINTAINERS info for Paul Moore
      doc: Update the email address for Paul Moore in various source files


 MAINTAINERS                         |    6 +++---
 include/net/cipso_ipv4.h            |    2 +-
 include/net/netlabel.h              |    2 +-
 net/netlabel/Makefile               |    2 --
 net/netlabel/netlabel_addrlist.c    |    2 +-
 net/netlabel/netlabel_addrlist.h    |    2 +-
 net/netlabel/netlabel_cipso_v4.c    |    2 +-
 net/netlabel/netlabel_cipso_v4.h    |    2 +-
 net/netlabel/netlabel_domainhash.c  |    2 +-
 net/netlabel/netlabel_domainhash.h  |    2 +-
 net/netlabel/netlabel_kapi.c        |    2 +-
 net/netlabel/netlabel_mgmt.c        |    2 +-
 net/netlabel/netlabel_mgmt.h        |    2 +-
 net/netlabel/netlabel_unlabeled.c   |    2 +-
 net/netlabel/netlabel_unlabeled.h   |    2 +-
 net/netlabel/netlabel_user.c        |    2 +-
 net/netlabel/netlabel_user.h        |    2 +-
 security/selinux/hooks.c            |    2 +-
 security/selinux/include/netif.h    |    2 +-
 security/selinux/include/netlabel.h |    2 +-
 security/selinux/include/netnode.h  |    2 +-
 security/selinux/include/netport.h  |    2 +-
 security/selinux/netif.c            |    2 +-
 security/selinux/netlabel.c         |    2 +-
 security/selinux/netnode.c          |    2 +-
 security/selinux/netport.c          |    2 +-
 security/selinux/selinuxfs.c        |    2 +-
 security/selinux/ss/ebitmap.c       |    2 +-
 security/selinux/ss/mls.c           |    2 +-
 security/selinux/ss/mls.h           |    2 +-
 security/selinux/ss/policydb.c      |    2 +-
 security/selinux/ss/services.c      |    2 +-
 security/smack/smack_lsm.c          |    2 +-
 33 files changed, 34 insertions(+), 36 deletions(-)

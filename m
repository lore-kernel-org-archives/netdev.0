From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Sat,  1 Oct 2011 12:34:17 +0900
Message-ID: <1317440059-31112-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

please consider pulling the following to get some
documentation changes from myself.

The following changes since commit 6fa4dec85e199f31774faf29be26a53329d02e9e:

  ipvs: Removed unused variables (2011-09-28 21:09:24 +0200)

are available in the git repository at:
  git@github.com:horms/ipvs-next.git master

Simon Horman (2):
      IPVS: secure_tcp does provide alternate state timeouts
      IPVS: Enhance grammar used to refer to Kconfig options

 Documentation/networking/ipvs-sysctl.txt |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

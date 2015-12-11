From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/2] Minor PPP devices improvements
Date: Fri, 11 Dec 2015 19:54:47 +0100
Message-ID: <cover.1449859708.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let PPP devices be friendlier to user space by registering their device
type and reporting their interface naming scheme.

Guillaume Nault (2):
  ppp: define "ppp" device type
  ppp: declare ppp devices as enumerated interfaces

 drivers/net/ppp/ppp_generic.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

-- 
2.6.4


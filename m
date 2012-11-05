From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 0/2 v2] net: at91_ether add dt and pinctrl support
Date: Mon, 5 Nov 2012 08:30:15 +0100
Message-ID: <20121105073015.GM19021@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
 Nicolas Ferre <nicolas.ferre@atmel.com>, Joachim Eastwood <manabian@gmail.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

	v2: fix typo in doc + miising empty line

	This patch serie add dt and pinctrl support to the at91 ether

	this is need to use the network on at91rm9200 as we now have dt
	support on it

Jean-Christophe PLAGNIOL-VILLARD (2):
      net: at91_ether: add dt support
      net: at91_ether: add pinctrl support

 Documentation/devicetree/bindings/net/cdns-emac.txt |   23 +++++++++++++++++++++++
 drivers/net/ethernet/cadence/at91_ether.c           |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 100 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/cdns-emac.txt

Best Regards,
J.

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

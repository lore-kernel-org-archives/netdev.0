From: Joe Perches <joe@perches.com>
Subject: [PATCH] drivers/net/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:08 -0800
Message-ID: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918891.git.joe__32222.5865711973$1197938872$gmane$org@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>,
	Eugene Surovegin <ebs@ebshome.net>,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	orinoco-devel@lists.sourceforge.net, Yi Zhu <yi.zhu@intel.com>,
	Jaroslav Kysela <perex@perex.cz>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	Peter De Shrijver <p2@ace.ulyssis.student.kuleuven.ac.be>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	bonding-devel@lists.sourceforge.net,
	Andy Gospodarek <andy@greyhouse.net>,
	"Amit S. Kale" <amitkale@netxen.com>,
	ipw2100-devel@lists.sourceforge.net,
	ipw3945-devel@lists.sourceforge.net,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>,
	libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
	Dale Farnsworth <dale@farnsworth.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Manish Lachwani <m
To: linux-kernel@vger.kernel.org
Return-path: <ipw2100-devel-bounces@lists.sourceforge.net>
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918891.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw2100-devel>
List-Post: <mailto:ipw2100-devel@lists.sourceforge.net>
List-Help: <mailto:ipw2100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw2100-devel-bounces@lists.sourceforge.net
Errors-To: ipw2100-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/82596.c                            |    2 +-
 drivers/net/amd8111e.c                         |    8 ++++----
 drivers/net/amd8111e.h                         |    2 +-
 drivers/net/appletalk/ltpc.c                   |    2 +-
 drivers/net/atl1/atl1_hw.c                     |    2 +-
 drivers/net/atl1/atl1_main.c                   |    2 +-
 drivers/net/bonding/bond_3ad.c                 |    4 ++--
 drivers/net/chelsio/sge.c                      |    2 +-
 drivers/net/chelsio/subr.c                     |    2 +-
 drivers/net/cxgb3/t3_hw.c                      |    2 +-
 drivers/net/e1000/e1000_hw.c                   |    4 ++--
 drivers/net/e1000/e1000_hw.h                   |    2 +-
 drivers/net/e1000/e1000_main.c                 |    2 +-
 drivers/net/e1000e/netdev.c                    |    2 +-
 drivers/net/eepro.c                            |    2 +-
 drivers/net/ehea/ehea.h                        |    2 +-
 drivers/net/forcedeth.c                        |    2 +-
 drivers/net/hamachi.c                          |    4 ++--
 drivers/net/hp100.c                            |    2 +-
 drivers/net/hp100.h                            |    4 ++--
 drivers/net/ibm_emac/ibm_emac.h                |    2 +-
 drivers/net/ibm_newemac/emac.h                 |    2 +-
 drivers/net/ibmlana.c                          |    2 +-
 drivers/net/ibmlana.h                          |    2 +-
 drivers/net/ipg.c                              |    4 ++--
 drivers/net/irda/ali-ircc.c                    |    6 +++---
 drivers/net/irda/ali-ircc.h                    |    4 ++--
 drivers/net/irda/donauboe.h                    |    2 +-
 drivers/net/irda/irport.c                      |    4 ++--
 drivers/net/irda/nsc-ircc.h                    |    4 ++--
 drivers/net/irda/smsc-ircc2.c                  |    4 ++--
 drivers/net/irda/via-ircc.h                    |    4 ++--
 drivers/net/ixgbe/ixgbe_common.c               |    4 ++--
 drivers/net/ixgbe/ixgbe_main.c                 |    2 +-
 drivers/net/lasi_82596.c                       |    2 +-
 drivers/net/lib82596.c                         |    2 +-
 drivers/net/macb.c                             |    2 +-
 drivers/net/meth.h                             |    2 +-
 drivers/net/mv643xx_eth.c                      |    4 ++--
 drivers/net/netxen/netxen_nic_hw.h             |    2 +-
 drivers/net/ppp_generic.c                      |    2 +-
 drivers/net/ps3_gelic_net.c                    |    2 +-
 drivers/net/qla3xxx.c                          |    2 +-
 drivers/net/s2io.h                             |    2 +-
 drivers/net/sis190.c                           |    2 +-
 drivers/net/sk98lin/skgepnmi.c                 |    2 +-
 drivers/net/sk98lin/skxmac2.c                  |    4 ++--
 drivers/net/skfp/ess.c                         |    2 +-
 drivers/net/skfp/fplustm.c                     |    6 +++---
 drivers/net/skfp/h/fplustm.h                   |    4 ++--
 drivers/net/skfp/h/smt.h                       |    2 +-
 drivers/net/skfp/h/supern_2.h                  |    2 +-
 drivers/net/smc911x.c                          |    2 +-
 drivers/net/spider_net.c                       |    2 +-
 drivers/net/sunbmac.h                          |    2 +-
 drivers/net/sungem.c                           |    2 +-
 drivers/net/sunhme.h                           |    2 +-
 drivers/net/tc35815.c                          |    4 ++--
 drivers/net/tehuti.c                           |    2 +-
 drivers/net/tehuti.h                           |    2 +-
 drivers/net/tokenring/3c359.c                  |    2 +-
 drivers/net/tokenring/lanstreamer.c            |    2 +-
 drivers/net/tokenring/olympic.c                |    2 +-
 drivers/net/tokenring/smctr.c                  |    6 +++---
 drivers/net/tokenring/tms380tr.c               |    2 +-
 drivers/net/tokenring/tms380tr.h               |    2 +-
 drivers/net/tulip/xircom_cb.c                  |    2 +-
 drivers/net/tun.c                              |    4 ++--
 drivers/net/ucc_geth_ethtool.c                 |    2 +-
 drivers/net/ucc_geth_mii.c                     |    6 +++---
 drivers/net/wan/cycx_drv.c                     |    4 ++--
 drivers/net/wan/sbni.c                         |    2 +-
 drivers/net/wireless/atmel.c                   |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h |    2 +-
 drivers/net/wireless/ipw2200.c                 |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c        |    2 +-
 drivers/net/wireless/libertas/cmd.c            |    4 ++--
 drivers/net/wireless/libertas/scan.c           |    4 ++--
 drivers/net/wireless/netwave_cs.c              |    2 +-
 drivers/net/wireless/orinoco.h                 |    2 +-
 drivers/net/wireless/ray_cs.c                  |    2 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h        |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h        |    6 +++---
 drivers/net/wireless/rt2x00/rt73usb.c          |    2 +-
 drivers/net/wireless/wavelan_cs.c              |    2 +-
 drivers/net/wireless/zd1211rw/zd_chip.h        |    4 ++--
 drivers/net/yellowfin.c                        |    2 +-
 87 files changed, 120 insertions(+), 120 deletions(-)

diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 2797da7..d999b63 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -19,7 +19,7 @@
    TBD:
    * look at deferring rx frames rather than discarding (as per tulip)
    * handle tx ring full as per tulip
-   * performace test to tune rx_copybreak
+   * performance test to tune rx_copybreak
 
    Most of my modifications relate to the braindead big-endian
    implementation by Intel.  When the i596 is operating in
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index e7fdd81..5cefe92 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1283,7 +1283,7 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 #ifdef CONFIG_AMD8111E_NAPI
 	if(intr0 & RINT0){
 		if(netif_rx_schedule_prep(dev, &lp->napi)){
-			/* Disable receive interupts */
+			/* Disable receive interrupts */
 			writel(RINTEN0, mmio + INTEN0);
 			/* Schedule a polling routine */
 			__netif_rx_schedule(dev, &lp->napi);
@@ -1493,7 +1493,7 @@ static void amd8111e_read_regs(struct amd8111e_priv *lp, u32 *buf)
 
 
 /*
-This function sets promiscuos mode, all-multi mode or the multicast address
+This function sets promiscuous mode, all-multi mode or the multicast address
 list to the device.
 */
 static void amd8111e_set_multicast_list(struct net_device *dev)
@@ -1522,7 +1522,7 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 		lp->mc_list = NULL;
 		lp->options &= ~OPTION_MULTICAST_ENABLE;
 		amd8111e_writeq(*(u64*)mc_filter,lp->mmio + LADRF);
-		/* disable promiscous mode */
+		/* disable promiscuous mode */
 		writel(PROM, lp->mmio + CMD2);
 		return;
 	}
@@ -2016,7 +2016,7 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	for(i = 0; i < ETH_ADDR_LEN; i++)
 		dev->dev_addr[i] = readb(lp->mmio + PADR + i);
 
-	/* Setting user defined parametrs */
+	/* Setting user defined parameters */
 	lp->ext_phy_option = speed_duplex[card_idx];
 	if(coalesce[card_idx])
 		lp->options |= OPTION_INTR_COAL_ENABLE;
diff --git a/drivers/net/amd8111e.h b/drivers/net/amd8111e.h
index 28c60a7..7d288de 100644
--- a/drivers/net/amd8111e.h
+++ b/drivers/net/amd8111e.h
@@ -614,7 +614,7 @@ typedef enum {
 #define CSTATE  1
 #define SSTATE  2
 
-/* Assume contoller gets data 10 times the maximum processing time */
+/* Assume controller gets data 10 times the maximum processing time */
 #define  REPEAT_CNT			10
 
 /* amd8111e decriptor flag definitions */
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 6ab2c2d..86a9496 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1233,7 +1233,7 @@ static int __init ltpc_setup(char *str)
 		if (ints[0] > 2) {
 			dma = ints[3];
 		}
-		/* ignore any other paramters */
+		/* ignore any other parameters */
 	}
 	return 1;
 }
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index 9d3bd22..82359f7 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -645,7 +645,7 @@ s32 atl1_init_hw(struct atl1_hw *hw)
 	atl1_init_flash_opcode(hw);
 
 	if (!hw->phy_configured) {
-		/* enable GPHY LinkChange Interrrupt */
+		/* enable GPHY LinkChange Interrupt */
 		ret_val = atl1_write_phy_reg(hw, 18, 0xC00);
 		if (ret_val)
 			return ret_val;
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 35b0a7d..7599163 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -575,7 +575,7 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 		return ATL1_SUCCESS;
 	}
 
-	/* change orignal link status */
+	/* change original link status */
 	if (netif_carrier_ok(netdev)) {
 		adapter->link_speed = SPEED_0;
 		netif_carrier_off(netdev);
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index cb3c6fa..96f0f24 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -869,7 +869,7 @@ static int ad_lacpdu_send(struct port *port)
 	lacpdu_header = (struct lacpdu_header *)skb_put(skb, length);
 
 	lacpdu_header->ad_header.destination_address = lacpdu_multicast_address;
-	/* Note: source addres is set to be the member's PERMANENT address, because we use it
+	/* Note: source address is set to be the member's PERMANENT address, because we use it
 	   to identify loopback lacpdus in receive. */
 	lacpdu_header->ad_header.source_address = *((struct mac_addr *)(slave->perm_hwaddr));
 	lacpdu_header->ad_header.length_type = PKT_TYPE_LACPDU;
@@ -912,7 +912,7 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 	marker_header = (struct bond_marker_header *)skb_put(skb, length);
 
 	marker_header->ad_header.destination_address = lacpdu_multicast_address;
-	/* Note: source addres is set to be the member's PERMANENT address, because we use it
+	/* Note: source address is set to be the member's PERMANENT address, because we use it
 	   to identify loopback MARKERs in receive. */
 	marker_header->ad_header.source_address = *((struct mac_addr *)(slave->perm_hwaddr));
 	marker_header->ad_header.length_type = PKT_TYPE_LACPDU;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index b301c04..ed17cd9 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -248,7 +248,7 @@ static void restart_sched(unsigned long);
  *
  * Interrupts are handled by a single CPU and it is likely that on a MP system
  * the application is migrated to another CPU. In that scenario, we try to
- * seperate the RX(in irq context) and TX state in order to decrease memory
+ * separate the RX(in irq context) and TX state in order to decrease memory
  * contention.
  */
 struct sge {
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index dc50151..7c95578 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -559,7 +559,7 @@ struct chelsio_vpd_t {
 #define EEPROM_MAX_POLL   4
 
 /*
- * Read SEEPROM. A zero is written to the flag register when the addres is
+ * Read SEEPROM. A zero is written to the flag register when the address is
  * written to the Control register. The hardware device will set the flag to a
  * one when 4B have been transferred to the Data register.
  */
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 522834c..2882e36 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -534,7 +534,7 @@ struct t3_vpd {
  *
  *	Read a 32-bit word from a location in VPD EEPROM using the card's PCI
  *	VPD ROM capability.  A zero is written to the flag bit when the
- *	addres is written to the control register.  The hardware device will
+ *	address is written to the control register.  The hardware device will
  *	set the flag to 1 when 4 bytes have been read into the data register.
  */
 int t3_seeprom_read(struct adapter *adapter, u32 addr, u32 *data)
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 7c6888c..fd7e6a8 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -803,7 +803,7 @@ e1000_initialize_hardware_bits(struct e1000_hw *hw)
                 E1000_WRITE_REG(hw, CTRL, reg_ctrl);
                 break;
             case e1000_80003es2lan:
-                /* improve small packet performace for fiber/serdes */
+                /* improve small packet performance for fiber/serdes */
                 if ((hw->media_type == e1000_media_type_fiber) ||
                     (hw->media_type == e1000_media_type_internal_serdes)) {
                     reg_tarc0 &= ~(1 << 20);
@@ -5001,7 +5001,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
             return -E1000_ERR_EEPROM;
     }
 
-    /* Eerd register EEPROM access requires no eeprom aquire/release */
+    /* Eerd register EEPROM access requires no eeprom acquire/release */
     if (eeprom->use_eerd == TRUE)
         return e1000_read_eeprom_eerd(hw, offset, words, data);
 
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index a2a86c5..e40e515 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1068,7 +1068,7 @@ struct e1000_ffvt_entry {
 
 #define E1000_KUMCTRLSTA 0x00034 /* MAC-PHY interface - RW */
 #define E1000_MDPHYA     0x0003C  /* PHY address - RW */
-#define E1000_MANC2H     0x05860  /* Managment Control To Host - RW */
+#define E1000_MANC2H     0x05860  /* Management Control To Host - RW */
 #define E1000_SW_FW_SYNC 0x05B5C /* Software-Firmware Synchronization - RW */
 
 #define E1000_GCR       0x05B00 /* PCI-Ex Control */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4f37506..24a2fc1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -235,7 +235,7 @@ static struct pci_driver e1000_driver = {
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 #ifdef CONFIG_PM
-	/* Power Managment Hooks */
+	/* Power Management Hooks */
 	.suspend  = e1000_suspend,
 	.resume   = e1000_resume,
 #endif
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4fd2e23..febe157 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4109,7 +4109,7 @@ static struct pci_driver e1000_driver = {
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 #ifdef CONFIG_PM
-	/* Power Managment Hooks */
+	/* Power Management Hooks */
 	.suspend  = e1000_suspend,
 	.resume   = e1000_resume,
 #endif
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 83bda6c..d3789c5 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1764,7 +1764,7 @@ module_param_array(io, int, NULL, 0);
 module_param_array(irq, int, NULL, 0);
 module_param_array(mem, int, NULL, 0);
 module_param(autodetect, int, 0);
-MODULE_PARM_DESC(io, "EtherExpress Pro/10 I/O base addres(es)");
+MODULE_PARM_DESC(io, "EtherExpress Pro/10 I/O base address(es)");
 MODULE_PARM_DESC(irq, "EtherExpress Pro/10 IRQ number(s)");
 MODULE_PARM_DESC(mem, "EtherExpress Pro/10 Rx buffer size(es) in kB (3-29)");
 MODULE_PARM_DESC(autodetect, "EtherExpress Pro/10 force board(s) detection (0-1)");
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 5f82a46..a50b238 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -251,7 +251,7 @@ struct ehea_qp_init_attr {
 };
 
 /*
- * Event Queue attributes, passed as paramter
+ * Event Queue attributes, passed as parameter
  */
 struct ehea_eq_attr {
 	u32 type;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a96583c..7119332 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -490,7 +490,7 @@ union ring_type {
 #define NV_RX3_VLAN_TAG_PRESENT (1<<16)
 #define NV_RX3_VLAN_TAG_MASK	(0x0000FFFF)
 
-/* Miscelaneous hardware related defines: */
+/* Miscellaneous hardware related defines: */
 #define NV_PCI_REGSZ_VER1      	0x270
 #define NV_PCI_REGSZ_VER2      	0x2d4
 #define NV_PCI_REGSZ_VER3      	0x604
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index ed407c8..683b289 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -86,7 +86,7 @@ static int force32;
 static int options[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 /* The Hamachi chipset supports 3 parameters each for Rx and Tx
- * interruput management.  Parameters will be loaded as specified into
+ * interrupt management.  Parameters will be loaded as specified into
  * the TxIntControl and RxIntControl registers.
  *
  * The registers are arranged as follows:
@@ -811,7 +811,7 @@ static int __devinit read_eeprom(void __iomem *ioaddr, int location)
 	return readb(ioaddr + EEData);
 }
 
-/* MII Managemen Data I/O accesses.
+/* MII Management Data I/O accesses.
    These routines assume the MDIO controller is idle, and do not exit until
    the command is finished. */
 
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 49421d1..8b90d64 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -2643,7 +2643,7 @@ static int hp100_login_to_vg_hub(struct net_device *dev, u_short force_relogin)
 		} else {
 			hp100_andb(~HP100_PROM_MODE, VG_LAN_CFG_2);
 			/* For ETR parts we need to reset the prom. bit in the training
-			 * register, otherwise promiscious mode won't be disabled.
+			 * register, otherwise promiscuous mode won't be disabled.
 			 */
 			if (lp->chip == HP100_CHIPID_LASSEN) {
 				hp100_andw(~HP100_MACRQ_PROMSC, TRAIN_REQUEST);
diff --git a/drivers/net/hp100.h b/drivers/net/hp100.h
index e6ca128..e74e45d 100644
--- a/drivers/net/hp100.h
+++ b/drivers/net/hp100.h
@@ -476,7 +476,7 @@
 #define HP100_MACRQ_REPEATER         0x0001	/* 1: MAC tells HUB it wants to be
 						 *    a cascaded repeater
 						 * 0: ... wants to be a DTE */
-#define HP100_MACRQ_PROMSC           0x0006	/* 2 bits: Promiscious mode
+#define HP100_MACRQ_PROMSC           0x0006	/* 2 bits: Promiscuous mode
 						 * 00: Rcv only unicast packets
 						 *     specifically addr to this
 						 *     endnode
@@ -488,7 +488,7 @@
 #define HP100_CARD_MACVER            0xe000	/* R: 3 bit Cards 100VG MAC version */
 #define HP100_MALLOW_REPEATER        0x0001	/* If reset, requested access as an
 						 * end node is allowed */
-#define HP100_MALLOW_PROMSC          0x0004	/* 2 bits: Promiscious mode
+#define HP100_MALLOW_PROMSC          0x0004	/* 2 bits: Promiscuous mode
 						 * 00: Rcv only unicast packets
 						 *     specifically addr to this
 						 *     endnode
diff --git a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
index 97ed22b..655be50 100644
--- a/drivers/net/ibm_emac/ibm_emac.h
+++ b/drivers/net/ibm_emac/ibm_emac.h
@@ -1,7 +1,7 @@
 /*
  * drivers/net/ibm_emac/ibm_emac.h
  *
- * Register definitions for PowerPC 4xx on-chip ethernet contoller
+ * Register definitions for PowerPC 4xx on-chip ethernet controller
  *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
diff --git a/drivers/net/ibm_newemac/emac.h b/drivers/net/ibm_newemac/emac.h
index 91cb096..49a540a 100644
--- a/drivers/net/ibm_newemac/emac.h
+++ b/drivers/net/ibm_newemac/emac.h
@@ -1,7 +1,7 @@
 /*
  * drivers/net/ibm_newemac/emac.h
  *
- * Register definitions for PowerPC 4xx on-chip ethernet contoller
+ * Register definitions for PowerPC 4xx on-chip ethernet controller
  *
  * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
  *                <benh@kernel.crashing.org>
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 91d83ac..5a9b6fa 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -481,7 +481,7 @@ static void InitBoard(struct net_device *dev)
 	if ((dev->flags & IFF_ALLMULTI) || (mcptr != NULL))
 		rcrval |= RCREG_AMC;
 
-	/* promiscous mode ? */
+	/* promiscuous mode ? */
 
 	if (dev->flags & IFF_PROMISC)
 		rcrval |= RCREG_PRO;
diff --git a/drivers/net/ibmlana.h b/drivers/net/ibmlana.h
index aa3ddbd..654af95 100644
--- a/drivers/net/ibmlana.h
+++ b/drivers/net/ibmlana.h
@@ -90,7 +90,7 @@ typedef struct {
 #define RCREG_ERR        0x8000	/* accept damaged and collided pkts */
 #define RCREG_RNT        0x4000	/* accept packets that are < 64     */
 #define RCREG_BRD        0x2000	/* accept broadcasts                */
-#define RCREG_PRO        0x1000	/* promiscous mode                  */
+#define RCREG_PRO        0x1000	/* promiscuous mode                 */
 #define RCREG_AMC        0x0800	/* accept all multicasts            */
 #define RCREG_LB_NONE    0x0000	/* no loopback                      */
 #define RCREG_LB_MAC     0x0200	/* MAC loopback                     */
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..27d12eb 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -209,7 +209,7 @@ static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
 	/*
-	 * The GMII mangement frame structure for a read is as follows:
+	 * The GMII management frame structure for a read is as follows:
 	 *
 	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
 	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
@@ -300,7 +300,7 @@ static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
 	/*
-	 * The GMII mangement frame structure for a read is as follows:
+	 * The GMII management frame structure for a read is as follows:
 	 *
 	 * |Preamble|st|op|phyad|regad|ta|      data      |idle|
 	 * |< 32 1s>|01|10|AAAAA|RRRRR|z0|DDDDDDDDDDDDDDDD|z   |
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 9f58452..94140f7 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -977,7 +977,7 @@ static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
 		/* Install FIR xmit handler*/
 		dev->hard_start_xmit = ali_ircc_fir_hard_xmit;		
 				
-		/* Enable Interuupt */
+		/* Enable Interrupt */
 		self->ier = IER_EOM; // benjamin 2000/11/20 07:24PM					
 				
 		/* Be ready for incomming frames */
@@ -1096,7 +1096,7 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 	outb(lcr,		  iobase+UART_LCR); /* Set 8N1	*/
 	outb(fcr,		  iobase+UART_FCR); /* Enable FIFO's */
 
-	/* without this, the conection will be broken after come back from FIR speed,
+	/* without this, the connection will be broken after come back from FIR speed,
 	   but with this, the SIR connection is harder to established */
 	outb((UART_MCR_DTR | UART_MCR_RTS | UART_MCR_OUT2), iobase+UART_MCR);
 	
@@ -1359,7 +1359,7 @@ static int ali_ircc_net_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 	
-	/* Turn on interrups */
+	/* Turn on interrupts */
 	outb(UART_IER_RDI , iobase+UART_IER);
 
 	/* Ready to play! */
diff --git a/drivers/net/irda/ali-ircc.h b/drivers/net/irda/ali-ircc.h
index e489c66..0787657 100644
--- a/drivers/net/irda/ali-ircc.h
+++ b/drivers/net/irda/ali-ircc.h
@@ -173,13 +173,13 @@ struct st_fifo {
 
 struct frame_cb {
 	void *start; /* Start of frame in DMA mem */
-	int len;     /* Lenght of frame in DMA mem */
+	int len;     /* Length of frame in DMA mem */
 };
 
 struct tx_fifo {
 	struct frame_cb queue[MAX_TX_WINDOW]; /* Info about frames in queue */
 	int             ptr;                  /* Currently being sent */
-	int             len;                  /* Lenght of queue */
+	int             len;                  /* Length of queue */
 	int             free;                 /* Next free slot */
 	void           *tail;                 /* Next free start in DMA mem */
 };
diff --git a/drivers/net/irda/donauboe.h b/drivers/net/irda/donauboe.h
index 1e67720..9db3cce 100644
--- a/drivers/net/irda/donauboe.h
+++ b/drivers/net/irda/donauboe.h
@@ -30,7 +30,7 @@
  *     or the type-DO IR port.
  *
  * IrDA chip set list from Toshiba Computer Engineering Corp.
- * model			method	maker	controler		Version 
+ * model			method	maker	controller		Version 
  * Portege 320CT	FIR,SIR Toshiba Oboe(Triangle) 
  * Portege 3010CT	FIR,SIR Toshiba Oboe(Sydney) 
  * Portege 3015CT	FIR,SIR Toshiba Oboe(Sydney) 
diff --git a/drivers/net/irda/irport.c b/drivers/net/irda/irport.c
index c79caa5..2b2a955 100644
--- a/drivers/net/irda/irport.c
+++ b/drivers/net/irda/irport.c
@@ -276,7 +276,7 @@ static void irport_start(struct irport_cb *self)
 	outb(UART_LCR_WLEN8, iobase+UART_LCR);  /* Reset DLAB */
 	outb((UART_MCR_DTR | UART_MCR_RTS | UART_MCR_OUT2), iobase+UART_MCR);
 	
-	/* Turn on interrups */
+	/* Turn on interrupts */
 	outb(UART_IER_RLSI | UART_IER_RDI |UART_IER_THRI, iobase+UART_IER);
 }
 
@@ -352,7 +352,7 @@ static void irport_change_speed(void *priv, __u32 speed)
 	outb(lcr,		  iobase+UART_LCR); /* Set 8N1	*/
 	outb(fcr,		  iobase+UART_FCR); /* Enable FIFO's */
 
-	/* Turn on interrups */
+	/* Turn on interrupts */
 	/* This will generate a fatal interrupt storm.
 	 * People calling us will do that properly - Jean II */
 	//outb(/*UART_IER_RLSI|*/UART_IER_RDI/*|UART_IER_THRI*/, iobase+UART_IER);
diff --git a/drivers/net/irda/nsc-ircc.h b/drivers/net/irda/nsc-ircc.h
index bbdc97f..29398a4 100644
--- a/drivers/net/irda/nsc-ircc.h
+++ b/drivers/net/irda/nsc-ircc.h
@@ -231,13 +231,13 @@ struct st_fifo {
 
 struct frame_cb {
 	void *start; /* Start of frame in DMA mem */
-	int len;     /* Lenght of frame in DMA mem */
+	int len;     /* Length of frame in DMA mem */
 };
 
 struct tx_fifo {
 	struct frame_cb queue[MAX_TX_WINDOW]; /* Info about frames in queue */
 	int             ptr;                  /* Currently being sent */
-	int             len;                  /* Lenght of queue */
+	int             len;                  /* Length of queue */
 	int             free;                 /* Next free slot */
 	void           *tail;                 /* Next free start in DMA mem */
 };
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 7e7b582..7fd9a48 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -1165,7 +1165,7 @@ void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
 	outb(lcr,		  iobase + UART_LCR); /* Set 8N1 */
 	outb(fcr,		  iobase + UART_FCR); /* Enable FIFO's */
 
-	/* Turn on interrups */
+	/* Turn on interrupts */
 	outb(UART_IER_RLSI | UART_IER_RDI | UART_IER_THRI, iobase + UART_IER);
 
 	IRDA_DEBUG(2, "%s() speed changed to: %d\n", __FUNCTION__, speed);
@@ -1930,7 +1930,7 @@ void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
 	outb(UART_LCR_WLEN8, sir_base + UART_LCR);  /* Reset DLAB */
 	outb((UART_MCR_DTR | UART_MCR_RTS | UART_MCR_OUT2), sir_base + UART_MCR);
 
-	/* Turn on interrups */
+	/* Turn on interrupts */
 	outb(UART_IER_RLSI | UART_IER_RDI |UART_IER_THRI, sir_base + UART_IER);
 
 	IRDA_DEBUG(3, "%s() - exit\n", __FUNCTION__);
diff --git a/drivers/net/irda/via-ircc.h b/drivers/net/irda/via-ircc.h
index 204b1b3..9d012f0 100644
--- a/drivers/net/irda/via-ircc.h
+++ b/drivers/net/irda/via-ircc.h
@@ -54,13 +54,13 @@ struct st_fifo {
 
 struct frame_cb {
 	void *start;		/* Start of frame in DMA mem */
-	int len;		/* Lenght of frame in DMA mem */
+	int len;		/* Length of frame in DMA mem */
 };
 
 struct tx_fifo {
 	struct frame_cb queue[MAX_TX_WINDOW + 2];	/* Info about frames in queue */
 	int ptr;		/* Currently being sent */
-	int len;		/* Lenght of queue */
+	int len;		/* Length of queue */
 	int free;		/* Next free slot */
 	void *tail;		/* Next free start in DMA mem */
 };
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 512e3b2..4b6359e 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -716,7 +716,7 @@ static s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
  *  bit-vector to set in the multicast table. The hardware uses 12 bits, from
  *  incoming rx multicast addresses, to determine the bit-vector to check in
  *  the MTA. Which of the 4 combination, of 12-bits, the hardware uses is set
- *  by the MO field of the MCSTCTRL. The MO field is set during initalization
+ *  by the MO field of the MCSTCTRL. The MO field is set during initialization
  *  to mc_filter_type.
  **/
 static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
@@ -1066,7 +1066,7 @@ s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 
 
 /**
- *  ixgbe_acquire_swfw_sync - Aquire SWFW semaphore
+ *  ixgbe_acquire_swfw_sync - Acquire SWFW semaphore
  *  @hw: pointer to hardware structure
  *  @mask: Mask to specify wich semaphore to acquire
  *
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 00bc525..25a9cc2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -592,7 +592,7 @@ quit_polling:
  * ixgbe_setup_msix - Initialize MSI-X interrupts
  *
  * ixgbe_setup_msix allocates MSI-X vectors and requests
- * interrutps from the kernel.
+ * interrupts from the kernel.
  **/
 static int ixgbe_setup_msix(struct ixgbe_adapter *adapter)
 {
diff --git a/drivers/net/lasi_82596.c b/drivers/net/lasi_82596.c
index efbae4b..1ba38c2 100644
--- a/drivers/net/lasi_82596.c
+++ b/drivers/net/lasi_82596.c
@@ -47,7 +47,7 @@
    TBD:
    * look at deferring rx frames rather than discarding (as per tulip)
    * handle tx ring full as per tulip
-   * performace test to tune rx_copybreak
+   * performance test to tune rx_copybreak
 
    Most of my modifications relate to the braindead big-endian
    implementation by Intel.  When the i596 is operating in
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index b59f442..c335d31 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -47,7 +47,7 @@
    TBD:
    * look at deferring rx frames rather than discarding (as per tulip)
    * handle tx ring full as per tulip
-   * performace test to tune rx_copybreak
+   * performance test to tune rx_copybreak
 
    Most of my modifications relate to the braindead big-endian
    implementation by Intel.  When the i596 is operating in
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 047ea7b..1367178 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -239,7 +239,7 @@ static int macb_mii_init(struct macb *bp)
 	struct eth_platform_data *pdata;
 	int err = -ENXIO, i;
 
-	/* Enable managment port */
+	/* Enable management port */
 	macb_writel(bp, NCR, MACB_BIT(MPE));
 
 	bp->mii_bus.name = "MACB_mii_bus",
diff --git a/drivers/net/meth.h b/drivers/net/meth.h
index a78dc1c..ecd0e97 100644
--- a/drivers/net/meth.h
+++ b/drivers/net/meth.h
@@ -127,7 +127,7 @@ typedef struct rx_packet {
 #define METH_ACCEPT_MY 0			/* 00: Accept PHY address only */
 #define METH_ACCEPT_MCAST 0x20	/* 01: Accept physical, broadcast, and multicast filter matches only */
 #define METH_ACCEPT_AMCAST 0x40	/* 10: Accept physical, broadcast, and all multicast packets */
-#define METH_PROMISC 0x60		/* 11: Promiscious mode */
+#define METH_PROMISC 0x60		/* 11: Promiscuous mode */
 
 #define METH_PHY_LINK_FAIL	BIT(7) /* 0: Link failure detection disabled, 1: Hardware scans for link failure in PHY */
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 651c269..c263c91 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -535,7 +535,7 @@ struct mv643xx_private {
 
 	int rx_resource_err;		/* Rx ring resource error flag */
 
-	/* Tx/Rx rings managment indexes fields. For driver use */
+	/* Tx/Rx rings management indexes fields. For driver use */
 
 	/* Next available and first returning Rx resource */
 	int rx_curr_desc_q, rx_used_desc_q;
@@ -757,7 +757,7 @@ static void mv643xx_eth_update_mac_address(struct net_device *dev)
 /*
  * mv643xx_eth_set_rx_mode
  *
- * Change from promiscuos to regular rx mode
+ * Change from promiscuous to regular rx mode
  *
  * Input :	pointer to ethernet interface network device structure
  * Output :	N/A
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 245bf13..236160a 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -429,7 +429,7 @@ typedef enum {
 #define netxen_get_niu_enable_ge(config_word)	\
 		_netxen_crb_get_bit(config_word, 1)
 
-/* Promiscous mode options (GbE mode only) */
+/* Promiscuous mode options (GbE mode only) */
 typedef enum {
 	NETXEN_NIU_PROMISC_MODE = 0,
 	NETXEN_NIU_NON_PROMISC_MODE
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 4f69037..9e1890f 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -2368,7 +2368,7 @@ find_compressor(int type)
 }
 
 /*
- * Miscelleneous stuff.
+ * Miscellaneous stuff.
  */
 
 static void
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 0a42bf5..5efc5b4 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1271,7 +1271,7 @@ static struct ethtool_ops gelic_net_ethtool_ops = {
 /**
  * gelic_net_tx_timeout_task - task scheduled by the watchdog timeout
  * function (to be called not under interrupt status)
- * @work: work is context of tx timout task
+ * @work: work is context of tx timeout task
  *
  * called as task when tx hangs, resets interface (if interface is up)
  */
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index a579111..da85b7f 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3691,7 +3691,7 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 		ql_sem_unlock(qdev, QL_DRVR_SEM_MASK);
 	} else {
 		printk(KERN_ERR PFX
-		       "%s: Could not aquire driver lock.\n",
+		       "%s: Could not acquire driver lock.\n",
 		       ndev->name);
 		goto err_lock;
 	}
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index cc1797a..63d45d4 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -740,7 +740,7 @@ struct mac_info {
 	u16 mc_pause_threshold_q0q3;
 	u16 mc_pause_threshold_q4q7;
 
-	void *stats_mem;	/* orignal pointer to allocated mem */
+	void *stats_mem;	/* original pointer to allocated mem */
 	dma_addr_t stats_mem_phy;	/* Physical address of the stat block */
 	u32 stats_mem_sz;
 	struct stat_block *stats_info;	/* Logical address of the stat block */
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 7200883..ff559e4 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -102,7 +102,7 @@ enum sis190_registers {
 	IntrStatus		= 0x20,
 	IntrMask		= 0x24,
 	IntrControl		= 0x28,
-	IntrTimer		= 0x2c,	// unused (Interupt Timer)
+	IntrTimer		= 0x2c,	// unused (Interrupt Timer)
 	PMControl		= 0x30,	// unused (Power Mgmt Control/Status)
 	rsv2			= 0x34,	// reserved
 	ROMControl		= 0x38,
diff --git a/drivers/net/sk98lin/skgepnmi.c b/drivers/net/sk98lin/skgepnmi.c
index b36dd9a..c761ff7 100644
--- a/drivers/net/sk98lin/skgepnmi.c
+++ b/drivers/net/sk98lin/skgepnmi.c
@@ -356,7 +356,7 @@ int Level)		/* Initialization level */
 	unsigned int	PortMax;	/* Number of ports */
 	unsigned int	PortIndex;	/* Current port index in loop */
 	SK_U16		Val16;		/* Multiple purpose 16 bit variable */
-	SK_U8		Val8;		/* Mulitple purpose 8 bit variable */
+	SK_U8		Val8;		/* Multiple purpose 8 bit variable */
 	SK_EVPARA	EventParam;	/* Event struct for timer event */
 	SK_PNMI_VCT	*pVctBackupData;
 
diff --git a/drivers/net/sk98lin/skxmac2.c b/drivers/net/sk98lin/skxmac2.c
index b4e7502..3994289 100644
--- a/drivers/net/sk98lin/skxmac2.c
+++ b/drivers/net/sk98lin/skxmac2.c
@@ -3891,7 +3891,7 @@ int SkXmOverflowStatus(
 SK_AC	*pAC,				/* adapter context */
 SK_IOC	IoC,				/* IO context */
 unsigned int Port,			/* Port Index (MAC_1 + n) */
-SK_U16	IStatus,			/* Interupt Status from MAC */
+SK_U16	IStatus,			/* Interrupt Status from MAC */
 SK_U64	SK_FAR *pStatus)	/* ptr for return overflow status value */
 {
 	SK_U64	Status;	/* Overflow status */
@@ -4036,7 +4036,7 @@ int SkGmOverflowStatus(
 SK_AC	*pAC,				/* adapter context */
 SK_IOC	IoC,				/* IO context */
 unsigned int Port,			/* Port Index (MAC_1 + n) */
-SK_U16	IStatus,			/* Interupt Status from MAC */
+SK_U16	IStatus,			/* Interrupt Status from MAC */
 SK_U64	SK_FAR *pStatus)	/* ptr for return overflow status value */
 {
 	SK_U64	Status;		/* Overflow status */
diff --git a/drivers/net/skfp/ess.c b/drivers/net/skfp/ess.c
index 62b0132..889f987 100644
--- a/drivers/net/skfp/ess.c
+++ b/drivers/net/skfp/ess.c
@@ -598,7 +598,7 @@ static void ess_send_alc_req(struct s_smc *smc)
 	req->cmd.sba_cmd = REQUEST_ALLOCATION ;
 
 	/*
-	 * set the parameter type and parameter lenght of all used
+	 * set the parameter type and parameter length of all used
 	 * parameters
 	 */
 
diff --git a/drivers/net/skfp/fplustm.c b/drivers/net/skfp/fplustm.c
index a45205d..b27a895 100644
--- a/drivers/net/skfp/fplustm.c
+++ b/drivers/net/skfp/fplustm.c
@@ -398,7 +398,7 @@ static void copy_tx_mac(struct s_smc *smc, u_long td, struct fddi_mac *mac,
 /* u_long td;		 transmit descriptor */
 /* struct fddi_mac *mac; mac frame pointer */
 /* unsigned off;	 start address within buffer memory */
-/* int len ;		 lenght of the frame including the FC */
+/* int len ;		 length of the frame including the FC */
 {
 	int	i ;
 	u_int	*p ;
@@ -1262,8 +1262,8 @@ Function	DOWNCALL/INTERN	(SMT, fplustm.c)
 
 Para	mode =	1	RX_ENABLE_ALLMULTI	enable all multicasts
 		2	RX_DISABLE_ALLMULTI	disable "enable all multicasts"
-		3	RX_ENABLE_PROMISC	enable promiscous
-		4	RX_DISABLE_PROMISC	disable promiscous
+		3	RX_ENABLE_PROMISC	enable promiscuous
+		4	RX_DISABLE_PROMISC	disable promiscuous
 		5	RX_ENABLE_NSA		enable reception of NSA frames
 		6	RX_DISABLE_NSA		disable reception of NSA frames
 
diff --git a/drivers/net/skfp/h/fplustm.h b/drivers/net/skfp/h/fplustm.h
index 98bbf65..586f055 100644
--- a/drivers/net/skfp/h/fplustm.h
+++ b/drivers/net/skfp/h/fplustm.h
@@ -237,8 +237,8 @@ struct s_smt_fp {
  */
 #define RX_ENABLE_ALLMULTI	1	/* enable all multicasts */
 #define RX_DISABLE_ALLMULTI	2	/* disable "enable all multicasts" */
-#define RX_ENABLE_PROMISC	3	/* enable promiscous */
-#define RX_DISABLE_PROMISC	4	/* disable promiscous */
+#define RX_ENABLE_PROMISC	3	/* enable promiscuous */
+#define RX_DISABLE_PROMISC	4	/* disable promiscuous */
 #define RX_ENABLE_NSA		5	/* enable reception of NSA frames */
 #define RX_DISABLE_NSA		6	/* disable reception of NSA frames */
 
diff --git a/drivers/net/skfp/h/smt.h b/drivers/net/skfp/h/smt.h
index 1ff5899..2976757 100644
--- a/drivers/net/skfp/h/smt.h
+++ b/drivers/net/skfp/h/smt.h
@@ -413,7 +413,7 @@ struct smt_p_reason {
 #define SMT_RDF_SUCCESS	0x00000003	/* success (PMF) */
 #define SMT_RDF_BADSET	0x00000004	/* bad set count (PMF) */
 #define SMT_RDF_ILLEGAL 0x00000005	/* read only (PMF) */
-#define SMT_RDF_NOPARAM	0x6		/* paramter not supported (PMF) */
+#define SMT_RDF_NOPARAM	0x6		/* parameter not supported (PMF) */
 #define SMT_RDF_RANGE	0x8		/* out of range */
 #define SMT_RDF_AUTHOR	0x9		/* not autohorized */
 #define SMT_RDF_LENGTH	0x0a		/* length error */
diff --git a/drivers/net/skfp/h/supern_2.h b/drivers/net/skfp/h/supern_2.h
index 5ba0b83..1074f96 100644
--- a/drivers/net/skfp/h/supern_2.h
+++ b/drivers/net/skfp/h/supern_2.h
@@ -386,7 +386,7 @@ struct tx_queue {
 #define	FM_MDISRCV	(4<<8)		/* disable receive function */
 #define	FM_MRES0	(5<<8)		/* reserve */
 #define	FM_MLIMPROM	(6<<8)		/* limited-promiscuous mode */
-#define FM_MPROMISCOUS	(7<<8)		/* address detection : promiscous */
+#define FM_MPROMISCOUS	(7<<8)		/* address detection : promiscuous */
 
 #define FM_SELSA	0x0800		/* select-short-address bit */
 
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 76cc1d3..648b904 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -466,7 +466,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		/* Align IP header to 32 bits
 		 * Note that the device is configured to add a 2
 		 * byte padding to the packet start, so we really
-		 * want to write to the orignal data pointer */
+		 * want to write to the original data pointer */
 		data = skb->data;
 		skb_reserve(skb, 2);
 		skb_put(skb,pkt_len-4);
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index bccae7e..7a7f5cd 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1826,7 +1826,7 @@ spider_net_enable_card(struct spider_net_card *card)
 
 	spider_net_write_reg(card, SPIDER_NET_ECMODE, SPIDER_NET_ECMODE_VALUE);
 
-	/* set chain tail adress for RX chains and
+	/* set chain tail address for RX chains and
 	 * enable DMA */
 	spider_net_enable_rxchtails(card);
 	spider_net_enable_rxdmac(card);
diff --git a/drivers/net/sunbmac.h b/drivers/net/sunbmac.h
index b563d3c..681442b 100644
--- a/drivers/net/sunbmac.h
+++ b/drivers/net/sunbmac.h
@@ -185,7 +185,7 @@
 #define BIGMAC_RXCFG_ENABLE    0x00000001 /* Enable the receiver                      */
 #define BIGMAC_RXCFG_FIFO      0x0000000e /* Default rx fthresh...                    */
 #define BIGMAC_RXCFG_PSTRIP    0x00000020 /* Pad byte strip enable                    */
-#define BIGMAC_RXCFG_PMISC     0x00000040 /* Enable promiscous mode                   */
+#define BIGMAC_RXCFG_PMISC     0x00000040 /* Enable promiscuous mode                  */
 #define BIGMAC_RXCFG_DERR      0x00000080 /* Disable error checking                   */
 #define BIGMAC_RXCFG_DCRCS     0x00000100 /* Disable CRC stripping                    */
 #define BIGMAC_RXCFG_ME        0x00000200 /* Receive packets addressed to me          */
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 6887214..097a065 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -780,7 +780,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 			break;
 
 		/* When writing back RX descriptor, GEM writes status
-		 * then buffer address, possibly in seperate transactions.
+		 * then buffer address, possibly in separate transactions.
 		 * If we don't wait for the chip to write both, we could
 		 * post a new buffer to this descriptor then have GEM spam
 		 * on the buffer address.  We sync on the RX completion
diff --git a/drivers/net/sunhme.h b/drivers/net/sunhme.h
index 90f446d..68bf4e1 100644
--- a/drivers/net/sunhme.h
+++ b/drivers/net/sunhme.h
@@ -223,7 +223,7 @@
 /* BigMac receive config register. */
 #define BIGMAC_RXCFG_ENABLE   0x00000001 /* Enable the receiver             */
 #define BIGMAC_RXCFG_PSTRIP   0x00000020 /* Pad byte strip enable           */
-#define BIGMAC_RXCFG_PMISC    0x00000040 /* Enable promiscous mode          */
+#define BIGMAC_RXCFG_PMISC    0x00000040 /* Enable promiscuous mode         */
 #define BIGMAC_RXCFG_DERR     0x00000080 /* Disable error checking          */
 #define BIGMAC_RXCFG_DCRCS    0x00000100 /* Disable CRC stripping           */
 #define BIGMAC_RXCFG_REJME    0x00000200 /* Reject packets addressed to me  */
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d887c05..0fbf96d 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -136,7 +136,7 @@ struct tc35815_regs {
 #define DMA_RxAlign_2          0x00800000
 #define DMA_RxAlign_3          0x00c00000
 #define DMA_M66EnStat          0x00080000 /* 1:66MHz Enable State            */
-#define DMA_IntMask            0x00040000 /* 1:Interupt mask                 */
+#define DMA_IntMask            0x00040000 /* 1:Interrupt mask                 */
 #define DMA_SWIntReq           0x00020000 /* 1:Software Interrupt request    */
 #define DMA_TxWakeUp           0x00010000 /* 1:Transmit Wake Up              */
 #define DMA_RxBigE             0x00008000 /* 1:Receive Big Endian            */
@@ -281,7 +281,7 @@ struct tc35815_regs {
 #define Int_IntMacTx           0x00000001 /* 1:Tx controller & Clear         */
 
 /* MD_CA bit asign --------------------------------------------------------- */
-#define MD_CA_PreSup           0x00001000 /* 1:Preamble Supress              */
+#define MD_CA_PreSup           0x00001000 /* 1:Preamble Suppress             */
 #define MD_CA_Busy             0x00000800 /* 1:Busy (Start Operation)        */
 #define MD_CA_Wr               0x00000400 /* 1:Write 0:Read                  */
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 21230c9..3ed1973 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -276,7 +276,7 @@ static irqreturn_t bdx_isr_napi(int irq, void *dev)
 			 * currently intrs are disabled (since we read ISR),
 			 * and we have failed to register next poll.
 			 * so we read the regs to trigger chip
-			 * and allow further interupts. */
+			 * and allow further interrupts. */
 			READ_REG(priv, regTXF_WPTR_0);
 			READ_REG(priv, regRXD_WPTR_0);
 		}
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index efd170f..992efa6 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -510,7 +510,7 @@ struct txd_desc {
 #define  GMAC_RX_FILTER_ACRC  0x0010	/* accept crc error */
 #define  GMAC_RX_FILTER_AM    0x0008	/* accept multicast */
 #define  GMAC_RX_FILTER_AB    0x0004	/* accept broadcast */
-#define  GMAC_RX_FILTER_PRM   0x0001	/* [0:1] promiscous mode */
+#define  GMAC_RX_FILTER_PRM   0x0001	/* [0:1] promiscuous mode */
 
 #define  MAX_FRAME_AB_VAL       0x3fff	/* 13:0 */
 
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 5d31519..9d7a0c9 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -75,7 +75,7 @@ static char version[] __devinitdata  =
 MODULE_AUTHOR("Mike Phillips <mikep@linuxtr.net>") ; 
 MODULE_DESCRIPTION("3Com 3C359 Velocity XL Token Ring Adapter Driver \n") ;
 
-/* Module paramters */
+/* Module parameters */
 
 /* Ring Speed 0,4,16 
  * 0 = Autosense   
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 47d84cd..21c4f3c 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -170,7 +170,7 @@ static char *open_min_error[] = {
 	"Monitor Contention failer for RPL", "FDX Protocol Error"
 };
 
-/* Module paramters */
+/* Module parameters */
 
 /* Ring Speed 0,4,16
  * 0 = Autosense         
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 74c1f0f..b1178f1 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -132,7 +132,7 @@ static char *open_min_error[] = {"No error", "Function Failure", "Signal Lost",
 				   "Reserved", "Reserved", "No Monitor Detected for RPL", 
 				   "Monitor Contention failer for RPL", "FDX Protocol Error"};
 
-/* Module paramters */
+/* Module parameters */
 
 MODULE_AUTHOR("Mike Phillips <mikep@linuxtr.net>") ; 
 MODULE_DESCRIPTION("Olympic PCI/Cardbus Chipset Driver") ; 
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 93da3a3..4238a61 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -2426,7 +2426,7 @@ static irqreturn_t smctr_interrupt(int irq, void *dev_id)
                                 break ;
 
                         /* Type 0x0E - TRC Initialization Sequence Interrupt
-                         * Subtype -- 00-FF Initializatin sequence complete
+                         * Subtype -- 00-FF Initialization sequence complete
                          */
                         case ISB_IMC_TRC_INTRNL_TST_STATUS:
                                 tp->status = INITIALIZED;
@@ -3055,8 +3055,8 @@ static int smctr_load_node_addr(struct net_device *dev)
  * disabled.!?
  *
  * NOTE 2: If the monitor_state is MS_BEACON_TEST_STATE and the receive_mask
- * has any multi-cast or promiscous bits set, the receive_mask needs to
- * be changed to clear the multi-cast or promiscous mode bits, the lobe_test
+ * has any multi-cast or promiscuous bits set, the receive_mask needs to
+ * be changed to clear the multi-cast or promiscuous mode bits, the lobe_test
  * run, and then the receive mask set back to its original value if the test
  * is successful.
  */
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index d5fa36d..b15435d 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -48,7 +48,7 @@
  *	25-Sep-99	AF	Uped TPL_NUM from 3 to 9
  *				Removed extraneous 'No free TPL'
  *	22-Dec-99	AF	Added Madge PCI Mk2 support and generalized
- *				parts of the initilization procedure.
+ *				parts of the initialization procedure.
  *	30-Dec-99	AF	Turned tms380tr into a library ala 8390.
  *				Madge support is provided in the abyss module
  *				Generic PCI support is in the tmspci module.
diff --git a/drivers/net/tokenring/tms380tr.h b/drivers/net/tokenring/tms380tr.h
index 7daf74e..1cbb8b8 100644
--- a/drivers/net/tokenring/tms380tr.h
+++ b/drivers/net/tokenring/tms380tr.h
@@ -441,7 +441,7 @@ typedef struct {
 #define PASS_FIRST_BUF_ONLY	0x0100	/* Passes only first internal buffer
 					 * of each received frame; FrameSize
 					 * of RPLs must contain internal
-					 * BUFFER_SIZE bits for promiscous mode.
+					 * BUFFER_SIZE bits for promiscuous mode.
 					 */
 #define ENABLE_FULL_DUPLEX_SELECTION	0x2000 
  					/* Enable the use of full-duplex
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 70befe3..5dad012 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -646,7 +646,7 @@ static void setup_descriptors(struct xircom_private *card)
 	}
 
 	wmb();
-	/* wite the transmit descriptor ring to the card */
+	/* write the transmit descriptor ring to the card */
 	address = (unsigned long) card->tx_dma_handle;
 	val =cpu_to_le32(address);
 	outl(val, card->io_port + CSR4);	/* xmit descr list address */
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 1f76446..fc9eada 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -142,7 +142,7 @@ add_multi(u32* filter, const u8* addr)
 	filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 }
 
-/** Remove the specified Ethernet addres from this multicast filter. */
+/** Remove the specified Ethernet address from this multicast filter. */
 static void
 del_multi(u32* filter, const u8* addr)
 {
@@ -399,7 +399,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		 * - the packet is addressed to us.
 		 * - the packet is broadcast.
 		 * - the packet is multicast and
-		 *   - we are multicast promiscous.
+		 *   - we are multicast promiscuous.
 		 *   - we belong to the multicast group.
 		 */
 		skb_copy_from_linear_data(skb, addr, min_t(size_t, sizeof addr,
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 9a9622c..f8d319b 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -7,7 +7,7 @@
  *
  * Limitation: 
  * Can only get/set setttings of the first queue.
- * Need to re-open the interface manually after changing some paramters.
+ * Need to re-open the interface manually after changing some parameters.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index df884f0..7c0d4a8 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -63,11 +63,11 @@ int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
 {
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
 
-	/* Setting up the MII Mangement Address Register */
+	/* Setting up the MII Management Address Register */
 	out_be32(&regs->miimadd,
 		 (mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | regnum);
 
-	/* Setting up the MII Mangement Control Register with the value */
+	/* Setting up the MII Management Control Register with the value */
 	out_be32(&regs->miimcon, value);
 
 	/* Wait till MII management write is complete */
@@ -85,7 +85,7 @@ int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
 	u16 value;
 
-	/* Setting up the MII Mangement Address Register */
+	/* Setting up the MII Management Address Register */
 	out_be32(&regs->miimadd,
 		 (mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | regnum);
 
diff --git a/drivers/net/wan/cycx_drv.c b/drivers/net/wan/cycx_drv.c
index d347d59..d14e667 100644
--- a/drivers/net/wan/cycx_drv.c
+++ b/drivers/net/wan/cycx_drv.c
@@ -322,7 +322,7 @@ static int cycx_data_boot(void __iomem *addr, u8 *code, u32 len)
 	void __iomem *pt_boot_cmd = addr + CMD_OFFSET;
 	u32 i;
 
-	/* boot buffer lenght */
+	/* boot buffer length */
 	writew(CFM_LOAD_BUFSZ, pt_boot_cmd + sizeof(u16));
 	writew(GEN_DEFPAR, pt_boot_cmd);
 
@@ -353,7 +353,7 @@ static int cycx_code_boot(void __iomem *addr, u8 *code, u32 len)
 	void __iomem *pt_boot_cmd = addr + CMD_OFFSET;
 	u32 i;
 
-	/* boot buffer lenght */
+	/* boot buffer length */
 	writew(CFM_LOAD_BUFSZ, pt_boot_cmd + sizeof(u16));
 	writew(GEN_DEFPAR, pt_boot_cmd);
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 2e8b5c2..74f87df 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -1472,7 +1472,7 @@ sbni_get_stats( struct net_device  *dev )
 static void
 set_multicast_list( struct net_device  *dev )
 {
-	return;		/* sbni always operate in promiscuos mode */
+	return;		/* sbni always operate in promiscuous mode */
 }
 
 
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 059ce3f..60dfdd9 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -3278,7 +3278,7 @@ static void atmel_smooth_qual(struct atmel_private *priv)
 	priv->wstats.qual.updated &= ~IW_QUAL_QUAL_INVALID;
 }
 
-/* deals with incoming managment frames. */
+/* deals with incoming management frames. */
 static void atmel_management_frame(struct atmel_private *priv,
 				   struct ieee80211_hdr_4addr *header,
 				   u16 frame_len, u8 rssi)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
index a40d1af..edf7d8f 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
@@ -28,7 +28,7 @@ struct bcm43xx_dfsentry {
 	struct bcm43xx_xmitstatus *xmitstatus_buffer;
 	int xmitstatus_ptr;
 	int xmitstatus_cnt;
-	/* We need a seperate buffer while printing to avoid
+	/* We need a separate buffer while printing to avoid
 	 * concurrency issues. (New xmitstatus can arrive
 	 * while we are printing).
 	 */
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 54f44e5..e24382f 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1144,7 +1144,7 @@ static void ipw_led_shutdown(struct ipw_priv *priv)
 /*
  * The following adds a new attribute to the sysfs representation
  * of this device driver (i.e. a new file in /sys/bus/pci/drivers/ipw/)
- * used for controling the debug level.
+ * used for controlling the debug level.
  *
  * See the level definitions in ipw for details.
  */
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 891f90d..e242647 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -4051,7 +4051,7 @@ static int iwl4965_tx_status_reply_compressed_ba(struct iwl_priv *priv,
 	agg->wait_for_ba = 0;
 	IWL_DEBUG_TX_REPLY("BA %d %d\n", agg->start_idx, ba_resp->ba_seq_ctl);
 	sh = agg->start_idx - SEQ_TO_INDEX(ba_seq_ctl>>4);
-	if (sh < 0) /* tbw something is wrong with indeces */
+	if (sh < 0) /* tbw something is wrong with indices */
 		sh += 0x100;
 
 	/* don't use 64 bits for now */
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index be5cfd8..31ee4f6 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -1120,7 +1120,7 @@ int libertas_set_mac_packet_filter(wlan_private * priv)
  *  @param cmd_action	command action: GET or SET
  *  @param wait_option	wait option: wait response or not
  *  @param cmd_oid	cmd oid: treated as sub command
- *  @param pdata_buf	A pointer to informaion buffer
+ *  @param pdata_buf	A pointer to information buffer
  *  @return 		0 or -1
  */
 int libertas_prepare_and_send_command(wlan_private * priv,
@@ -1606,7 +1606,7 @@ static void cleanup_cmdnode(struct cmd_ctrl_node *ptempnode)
  *  @param ptempnode	A pointer to cmd_ctrl_node structure
  *  @param cmd_oid	cmd oid: treated as sub command
  *  @param wait_option	wait option: wait response or not
- *  @param pdata_buf	A pointer to informaion buffer
+ *  @param pdata_buf	A pointer to information buffer
  *  @return 		0 or -1
  */
 void libertas_set_cmd_ctrl_node(wlan_private * priv,
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index ad1e67d..537b36c 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -443,7 +443,7 @@ wlan_scan_setup_scan_config(wlan_private * priv,
 	ptlvpos = pscancfgout->tlvbuffer;
 
 	/*
-	 * Set the initial scan paramters for progressive scanning.  If a specific
+	 * Set the initial scan parameters for progressive scanning.  If a specific
 	 *   BSSID or SSID is used, the number of channels in the scan command
 	 *   will be increased to the absolute maximum
 	 */
@@ -1679,7 +1679,7 @@ int libertas_get_scan(struct net_device *dev, struct iw_request_info *info,
  *
  *  Called from libertas_prepare_and_send_command() in cmd.c
  *
- *  Sends a fixed lenght data part (specifying the BSS type and BSSID filters)
+ *  Sends a fixed length data part (specifying the BSS type and BSSID filters)
  *  as well as a variable number/length of TLVs to the firmware.
  *
  *  @param priv       A pointer to wlan_private structure
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index d2fa079..c4b649e 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -1408,7 +1408,7 @@ static void set_multicast_list(struct net_device *dev)
 	/* Multicast Mode */
 	rcvMode = rxConfRxEna + rxConfAMP + rxConfBcast;
     } else if (dev->flags & IFF_PROMISC) {
-	/* Promiscous mode */
+	/* Promiscuous mode */
 	rcvMode = rxConfRxEna + rxConfPro + rxConfAMP + rxConfBcast;
     } else {
 	/* Normal mode */
diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
index 4720fb2..703a4cf 100644
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -108,7 +108,7 @@ struct orinoco_private {
 	int	scan_inprogress;	/* Scan pending... */
 	u32	scan_mode;		/* Type of scan done */
 	char *	scan_result;		/* Result of previous scan */
-	int	scan_len;		/* Lenght of result */
+	int	scan_len;		/* Length of result */
 };
 
 #ifdef ORINOCO_DEBUG
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index f87fe10..24f9066 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -129,7 +129,7 @@ static void ray_reset(struct net_device *dev);
 static void ray_update_parm(struct net_device *dev, UCHAR objid, UCHAR *value, int len);
 static void verify_dl_startup(u_long);
 
-/* Prototypes for interrpt time functions **********************************/
+/* Prototypes for interrupt time functions **********************************/
 static irqreturn_t ray_interrupt (int reg, void *dev_id);
 static void clear_interrupt(ray_dev_t *local);
 static void rx_deauthenticate(ray_dev_t *local, struct rcs __iomem *prcs, 
diff --git a/drivers/net/wireless/rt2x00/rt2x00reg.h b/drivers/net/wireless/rt2x00/rt2x00reg.h
index 8384212..fe9011d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00reg.h
+++ b/drivers/net/wireless/rt2x00/rt2x00reg.h
@@ -230,7 +230,7 @@ static inline u8 rt2x00_get_field8(const u8 reg,
  *	corresponds with the TX register format for the current device.
  *	4 - plcp, 802.11b rates are device specific,
  *	802.11g rates are set according to the ieee802.11a-1999 p.14.
- * The bit to enable preamble is set in a seperate define.
+ * The bit to enable preamble is set in a separate define.
  */
 #define DEV_RATE	FIELD32(0x000007ff)
 #define DEV_PREAMBLE	FIELD32(0x00000800)
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.h b/drivers/net/wireless/rt2x00/rt2x00usb.h
index 2681abe..b76881f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.h
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.h
@@ -135,13 +135,13 @@ static inline int rt2x00usb_vendor_request_sw(const struct rt2x00_dev
  * kmalloc for correct handling inside the kernel USB layer.
  */
 static inline int rt2x00usb_eeprom_read(const struct rt2x00_dev *rt2x00dev,
-					 __le16 *eeprom, const u16 lenght)
+					 __le16 *eeprom, const u16 length)
 {
-	int timeout = REGISTER_TIMEOUT * (lenght / sizeof(u16));
+	int timeout = REGISTER_TIMEOUT * (length / sizeof(u16));
 
 	return rt2x00usb_vendor_request(rt2x00dev, USB_EEPROM_READ,
 					USB_VENDOR_REQUEST_IN, 0x0000,
-					0x0000, eeprom, lenght, timeout);
+					0x0000, eeprom, length, timeout);
 }
 
 /*
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index c0671c2..d1468a1 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -833,7 +833,7 @@ static int rt73usb_load_firmware(struct rt2x00_dev *rt2x00dev, void *data,
 
 	/*
 	 * Write firmware to device.
-	 * We setup a seperate cache for this action,
+	 * We setup a separate cache for this action,
 	 * since we are going to write larger chunks of data
 	 * then normally used cache size.
 	 */
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index 577c647..5d28105 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -159,7 +159,7 @@ psa_read(struct net_device *	dev,
 
 /*------------------------------------------------------------------*/
 /*
- * Write the Paramter Storage Area to the WaveLAN card's memory
+ * Write the Parameter Storage Area to the WaveLAN card's memory
  */
 static void
 psa_write(struct net_device *	dev,
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 8009b70..301315a 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -620,8 +620,8 @@ enum {
 #define E2P_PWR_INT_GUARD		8
 #define E2P_CHANNEL_COUNT		14
 
-/* If you compare this addresses with the ZYDAS orignal driver, please notify
- * that we use word mapping for the EEPROM.
+/* If you compare these addresses with the ZYDAS original driver,
+ * please notice that we use word mapping for the EEPROM.
  */
 
 /*
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 87f002a..cb6e978 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -533,7 +533,7 @@ static int __devinit read_eeprom(void __iomem *ioaddr, int location)
 	return ioread8(ioaddr + EERead);
 }
 
-/* MII Managemen Data I/O accesses.
+/* MII Management Data I/O accesses.
    These routines assume the MDIO controller is idle, and do not exit until
    the command is finished. */
 
-- 
1.5.3.7.949.g2221a6


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace

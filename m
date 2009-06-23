From: Mike Rapoport <mike@compulab.co.il>
Subject: smsc9220 with omap3
Date: Tue, 23 Jun 2009 19:09:22 +0300
Message-ID: <4A40FE32.1030708@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ARM Linux <linux-arm-kernel@lists.arm.linux.org.uk>
To: steve.glendinning@smsc.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Hi,
I'm trying to enable smsc9220 chip with OMAP3EVM board. Till now I was able to
get as far as "eth1: smsc911x_mii_probe: Failed Loop Back Test" error message
after a bunch of "eth1: smsc911x_phy_check_loopbackpkt: Failed to transmit
during loopback test".
Does anybody have a clue what's going wrong?

-- 
Sincerely yours,
Mike.


-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php

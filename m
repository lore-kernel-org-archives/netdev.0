From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] Add Fixed PHY support for ucc_geth
Date: Wed, 02 Apr 2008 14:15:52 +0200
Message-ID: <1207138552.9675.61.camel@gentoo-jocke.transmode.se>
References: <>
	 <1205833615-15833-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF029708189001D1954D@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Netdev <netdev@vger.kernel.org>,
	"Linuxppc-Embedded@Ozlabs.Org" <linuxppc-embedded@ozlabs.org>
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:12826 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752563AbYDBMPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 08:15:53 -0400
In-Reply-To: <989B956029373F45A0B8AF029708189001D1954D@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-03-21 at 16:51 +0800, Li Yang wrote:
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> > Sent: Tuesday, March 18, 2008 5:47 PM
> > To: Netdev; Li Yang; Linuxppc-Embedded@Ozlabs.Org
> > Cc: Joakim Tjernlund
> > Subject: [PATCH] Add Fixed PHY support for ucc_geth
> > 
> > The new Fixed PHY method, fixed-link property, isn't
> > impl. for ucc_geth which makes fixed PHYs non functional.
> > Add support for the new method to restore the Fixed PHY
> > functionality.
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> 
> ---
> Ps: This patch depends on the patch "ucc_geth: use correct thread number
> for 10/100Mbps link" to apply, which hasn't made to Linus' tree for now
> but has already been in Jeff and David's trees.

What happened to this patch? It is not in Linus tree.

 Jocke

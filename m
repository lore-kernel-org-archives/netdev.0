From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] drivers/net/: all drivers/net/ cleanup with ARRAY_SIZE
Date: Thu, 13 Sep 2007 00:10:57 -0400
Message-ID: <46E8B851.7080107@garzik.org>
References: <Pine.LNX.4.64.0709020235420.22012@localhost.localdomain> <11887290181154-git-send-email-crquan@gmail.com> <11887290302449-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Robert P. J. Day" <rpjday@mindspring.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cr_quan@163.com
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46635 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbXIMELG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:11:06 -0400
In-Reply-To: <11887290302449-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Cheng wrote:
> Signed-off-by: Denis Cheng <crquan@gmail.com>
> ---
>  drivers/net/apne.c                         |    2 +-
>  drivers/net/arm/am79c961a.c                |    2 +-
>  drivers/net/atarilance.c                   |    2 +-
>  drivers/net/atl1/atl1_hw.c                 |    2 +-
>  drivers/net/bnx2.c                         |    2 +-
>  drivers/net/cs89x0.c                       |    6 +++---
>  drivers/net/e1000/e1000_ethtool.c          |    3 +--
>  drivers/net/fec_8xx/fec_mii.c              |    5 ++---
>  drivers/net/ibm_emac/ibm_emac_debug.c      |    8 ++++----
>  drivers/net/irda/actisys-sir.c             |    2 +-
>  drivers/net/ixgb/ixgb_ethtool.c            |    3 +--
>  drivers/net/lp486e.c                       |    4 +---
>  drivers/net/mv643xx_eth.c                  |    3 +--
>  drivers/net/ne-h8300.c                     |    2 +-
>  drivers/net/ne.c                           |    2 +-
>  drivers/net/ne2.c                          |    2 +-
>  drivers/net/ne2k-pci.c                     |    2 +-
>  drivers/net/netxen/netxen_nic.h            |    2 +-
>  drivers/net/netxen/netxen_nic_hw.c         |    2 +-
>  drivers/net/pcmcia/axnet_cs.c              |    2 +-
>  drivers/net/pcmcia/pcnet_cs.c              |    4 ++--
>  drivers/net/phy/phy.c                      |    2 +-
>  drivers/net/skfp/smt.c                     |    2 +-
>  drivers/net/skfp/srf.c                     |    4 ++--
>  drivers/net/tulip/de4x5.c                  |    6 +++---
>  drivers/net/wireless/airo.c                |    6 +++---
>  drivers/net/wireless/hostap/hostap_ioctl.c |    6 +++---
>  drivers/net/wireless/ipw2100.c             |    7 +++----
>  drivers/net/wireless/libertas/fw.c         |    3 +--
>  drivers/net/wireless/libertas/main.c       |   14 +++++++-------
>  drivers/net/wireless/libertas/wext.c       |    4 ++--
>  drivers/net/wireless/netwave_cs.c          |    6 +++---
>  drivers/net/wireless/prism54/isl_ioctl.c   |    7 +++----
>  drivers/net/wireless/ray_cs.c              |    6 +++---
>  drivers/net/wireless/wavelan.c             |    6 +++---
>  drivers/net/wireless/wavelan_cs.c          |    6 +++---
>  drivers/net/wireless/wl3501_cs.c           |    2 +-
>  drivers/net/zorro8390.c                    |    2 +-
>  38 files changed, 71 insertions(+), 80 deletions(-)

applied



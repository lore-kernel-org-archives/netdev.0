From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/3] bcm43xx-d80211: fix whitespace
Date: Sat, 6 May 2006 19:43:51 +0200
Message-ID: <200605061943.51654.mb@bu3sch.de>
References: <20060505215542.25d310dd@localhost> <20060505215959.35be978d@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:33937
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750967AbWEFRhL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 13:37:11 -0400
To: Stefano Brivio <stefano.brivio@polimi.it>
In-Reply-To: <20060505215959.35be978d@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 May 2006 21:59, Stefano Brivio wrote:
> Fix whitespace.
> 
> Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>
> 
> Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:00.370034536 +0200
> +++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 02:43:44.981535888 +0200

All your d80211 patches are _not_ against the dscape port
of the bcm43xx driver. The dscape port is located at:
wireless-dev/drivers/net/wireless/d80211/bcm43xx/

> @@ -128,13 +128,13 @@
>  	static struct pci_device_id bcm43xx_pci_tbl[] = {
>  	/* Broadcom 4303 802.11b */
>  	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> -		/* Broadcom 4307 802.11b */
> +	/* Broadcom 4307 802.11b */
>  	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> -		/* Broadcom 4318 802.11b/g */
> +	/* Broadcom 4318 802.11b/g */
>  	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
>  	/* Broadcom 4306 802.11b/g */
>  	{ PCI_VENDOR_ID_BROADCOM, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> -		/* Broadcom 4306 802.11a */
> +	/* Broadcom 4306 802.11a */
>  //	{ PCI_VENDOR_ID_BROADCOM, 0x4321, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
>  	/* Broadcom 4309 802.11a/b/g */
>  	{ PCI_VENDOR_ID_BROADCOM, 0x4324, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
> 
> 
> --
> Ciao
> Stefano
> _______________________________________________
> Bcm43xx-dev mailing list
> Bcm43xx-dev@lists.berlios.de
> http://lists.berlios.de/mailman/listinfo/bcm43xx-dev
> 

-- 
Greetings Michael.

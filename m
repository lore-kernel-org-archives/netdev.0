From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Wed, 19 Sep 2007 17:18:11 -0400
Message-ID: <9e4733910709191418o1fba9009gdc75c6bdb56fccd1@mail.gmail.com>
References: <20070810095153.GC13994@moe.telargo.com>
	 <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
	 <20070915121444.GA19857@nd47.coderock.org>
	 <20070917095334.GA4546@powerlinux.fr>
	 <20070917202140.GB2642@nd47.coderock.org>
	 <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
	 <20070918151622.GD32628@nd47.coderock.org>
	 <9e4733910709181217v417438s85bb9e6b4ad4b475@mail.gmail.com>
	 <20070919115621.GI32628@nd47.coderock.org>
	 <9e4733910709191144l6ddb66eaq84f3d1488bcf1443@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org,
	sven@powerlinux.fr
To: "Domen Puncer" <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:64999 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbXISVSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 17:18:12 -0400
Received: by wa-out-1112.google.com with SMTP id v27so371318wah
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 14:18:11 -0700 (PDT)
In-Reply-To: <9e4733910709191144l6ddb66eaq84f3d1488bcf1443@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/19/07, Jon Smirl <jonsmirl@gmail.com> wrote:
> This needs a cleanup too, but it is unrelated....

Another set of related warnings that need clean up....

  CC      drivers/spi/mpc52xx_psc_spi.o
drivers/spi/mpc52xx_psc_spi.c: In function 'mpc52xx_psc_spi_activate_cs':
drivers/spi/mpc52xx_psc_spi.c:110: warning: passing argument 1 of
'in_be16' from incompatible pointer type
drivers/spi/mpc52xx_psc_spi.c:116: warning: passing argument 1 of
'out_be16' from incompatible pointer type
drivers/spi/mpc52xx_psc_spi.c: In function 'mpc52xx_psc_spi_port_config':
drivers/spi/mpc52xx_psc_spi.c:417: warning: passing argument 1 of
'out_be16' from incompatible pointer type


-- 
Jon Smirl
jonsmirl@gmail.com

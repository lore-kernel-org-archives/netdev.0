From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.17-mm2: no QLA3YYY_NAPI help text
Date: Sun, 25 Jun 2006 18:47:41 +0200
Message-ID: <20060625164741.GB23314@stusta.de>
References: <20060624061914.202fbfb5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:63759 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1751167AbWFYQrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 12:47:43 -0400
To: Andrew Morton <akpm@osdl.org>, Ron Mercer <ron.mercer@qlogic.com>
Content-Disposition: inline
In-Reply-To: <20060624061914.202fbfb5.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ resent with a subject adapted to vger mail filter... ]

On Sat, Jun 24, 2006 at 06:19:14AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.17-mm1:
>...
> +qla3xxx-NIC-driver.patch
>...
>  Net driver updates.  Includes a new driver from qlogic which almost compiles.
>...

The QLA3XXX_NAPI option lacks a help text.

Please add a help text.

TIA
Adrian

--

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


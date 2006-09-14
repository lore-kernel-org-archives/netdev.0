From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: [PATCH] bcm43xx: fix netdev watchdog timeouts
Date: Thu, 14 Sep 2006 15:37:14 +0200
Message-ID: <20060914133714.GF1845@harddisk-recovery.com>
References: <45095916.mailNQM11V1HV@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Michael Buesch <mb@bu3sch.de>,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:41097 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S1750718AbWINNhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 09:37:16 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <45095916.mailNQM11V1HV@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2006 at 08:28:54AM -0500, Larry Finger wrote:
> Please apply this to wireless-2.6. It would be great if this patch were to be
> included in 2.6.19.

I suppose you mean 2.6.18?

It would also be nice if your "bcm43xx locks up machine" patch were to
be included in 2.6.18 together with this patch or we will see
regression reports against 2.6.17.


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands

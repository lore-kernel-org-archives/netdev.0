From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Mon, 23 Oct 2006 12:36:32 -0400
Message-ID: <453CEF90.1090403@gentoo.org>
References: <45330803.mail261110C22@lwfinger.net> <200610231529.05471.mb@bu3sch.de> <453CD325.3020003@gentoo.org> <200610231641.45011.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.iad.emailsrvr.com ([207.97.245.121]:21647 "EHLO
	smtp121.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1751998AbWJWQhh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 12:37:37 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610231641.45011.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Yes. 2.6.19-rc is still older code than 2.6.18.1.
> The stuff from 2.6.18.1 (which is the same as wireless-2.6)
> will be merged into 2.6.19-rc soon.

2.6.18.1 produced the oops in the earlier mail
wireless-2.6 did *not* produce the oops, instead I get the behavior of
plain 2.6.19-rc2 plus PCI-E patch (i.e. _almost_ works)

Daniel



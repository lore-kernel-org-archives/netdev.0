From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Mon, 23 Oct 2006 09:49:52 -0400
Message-ID: <453CC880.1020801@gentoo.org>
References: <45330803.mail261110C22@lwfinger.net> <200610201855.21183.mb@bu3sch.de> <453914AE.2090604@gentoo.org> <200610202037.47758.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.iad.emailsrvr.com ([207.97.245.121]:44774 "EHLO
	smtp121.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1750956AbWJWNuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 09:50:50 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610202037.47758.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Please try 2.6.18.1 or wireless-2.6.

wireless-2.6.git has the same problems as the earlier reports on 
2.6.19-rc2: ifconfig up,down,up fails, plus it's hard to get connectivity.

Daniel

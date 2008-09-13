From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 2.6.28] myri10ge: use DCA if DCA is compiled as a module
Date: Sat, 13 Sep 2008 22:38:49 +0200
Message-ID: <48CC24D9.7070707@myri.com>
References: <48CC22CE.8050608@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1868 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751643AbYIMUjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 16:39:53 -0400
In-Reply-To: <48CC22CE.8050608@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Use DCA in myri10ge when CONFIG_DCA_MODULE is set as well.
>   

This one misses the Kconfig stuff to prevent DCA=m when myri10ge=y, I'll
resend soon.

Brice


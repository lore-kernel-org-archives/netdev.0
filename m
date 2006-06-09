From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Thu, 08 Jun 2006 22:40:05 -0400
Message-ID: <4488DF85.3090901@garzik.org>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:30691 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965082AbWFICkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 22:40:09 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060608143133.7e36a0b7.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> Conversely, any reason to use the RealTek r1000 driver?

FWIW, RealTek emailed me about merging r1000.  I suggested that, if the 
register sets were similar, that r8169 should be updated instead, to 
preserve compatibility with existing users (and not lose existing work).

	Jeff



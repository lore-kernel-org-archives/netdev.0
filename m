From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Thu, 21 Feb 2008 21:19:02 +0900
Message-ID: <1203596342.15409.68.camel@shinybook.infradead.org>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
	 <1203428949.3223.25.camel@shinybook.infradead.org>
	 <47BAE13D.4060206@trash.net>
	 <1203431447.3223.33.camel@shinybook.infradead.org>
	 <47BAEB6C.1030609@trash.net>
	 <1203594725.15409.48.camel@shinybook.infradead.org>
	 <47BD67DD.6020404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51330 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbYBUMTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 07:19:06 -0500
In-Reply-To: <47BD67DD.6020404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-02-21 at 13:00 +0100, Patrick McHardy wrote:
> I already sent it to Dave for 2.6.25 (I assume that what you meant,
> it was introduced after 2.6.24), its currently sitting in net-2.6
> and should hit Linus' tree next time he pulls from Dave.

I actually meant 2.6.24.x, because I thought the offending patch was in
2.6.24. I didn't realise we were building against post-2.6.24 kernel
headers in Fedora rawhide already. So that'll be fine -- thanks.

-- 
dwmw2


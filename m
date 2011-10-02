From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Fwd: wrong VENDOR_ID 10ac
Date: Sun, 02 Oct 2011 16:14:34 +0100
Message-ID: <1317568476.4068.95.camel@deadeye>
References: <CAPZBsThhGxpvioOKuCffOiJXKiZs47RQ2bT-ZSaVSM5Eigxkog@mail.gmail.com>
	 <CAPZBsTgtfeZFoLENX7K9Hii7-SFpCQas80ka9cokx=0UPQEfhw@mail.gmail.com>
	 <CAPZBsTi6a1necbvEANP4Sx=Ovo-ntPLyiFfus3dDiKBrSvkc7w@mail.gmail.com>
	 <CAPZBsTg_UjUGuNFbyh+D31swOaQSdA_U9Apx8z6oQsrSNe3ohw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian Vasquez Perales <christian.vasquez.perales@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57986 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab1JBPOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 11:14:46 -0400
In-Reply-To: <CAPZBsTg_UjUGuNFbyh+D31swOaQSdA_U9Apx8z6oQsrSNe3ohw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-10-02 at 06:31 +0100, Christian Vasquez Perales wrote:
> Hello,
> 
> May be you can help me, I have bought 2 identical trendnet TEG-PCITXR
> gigabit cards, and my centos has detected automatically just 1 of the
> 2 cards and this card is working fine with the driver r8169, but the
> other is not recognized,
> 
> As per my investigation, the VENDOR_ID in the wrong card is 10ac, and
> it must to be 10ec (according the PCI database), please see the
> attached with the output from lspci and setpci,
> 
> Could you give me some ideas? or do you know how to change the
> Vendor_ID in a network card?
[...]

There's no generic way to do this.  I suggest you return the faulty card
for a refund/replacement; there is quite possibly more wrong with it
than this one-bit error.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

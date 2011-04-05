From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 05 Apr 2011 13:12:02 +0200
Message-ID: <8739lxx88t.fsf@macbook.be.48ers.dk>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<20110316.131734.242138246.davem@davemloft.net>
	<4D86F25A.7060405@atmel.com>
	<20110321111838.GC2610@pulham.picochip.com>
	<20110322161811.GF6466@game.jcrosoft.org>
	<20110322163917.GD10058@pulham.picochip.com>
	<20110322175523.GE10058@pulham.picochip.com>
	<20110324162517.GI6466@game.jcrosoft.org>
	<20110331094041.GD3371@pulham.picochip.com>
	<20110405102842.GC22192@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Andrew Victor <linux@maxim.org.za>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52656 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab1DELML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 07:12:11 -0400
Received: by wwk4 with SMTP id 4so2606000wwk.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 04:12:10 -0700 (PDT)
In-Reply-To: <20110405102842.GC22192@game.jcrosoft.org> (Jean-Christophe
	PLAGNIOL-VILLARD's message of "Tue, 5 Apr 2011 12:28:42 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Jean-Christophe" == Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com> writes:

Hi,

 JC> work fine on 9263ek except the IP version detection.

 JC> the at91 macb ip version is supposed to be at 0x0601010C but it's not.
 JC> At least on 9263 it's 0x0001010C. So we can not detect the arch at runtime
 JC> but we can detect that it's a macb.

Same here on a 9g45.

-- 
Bye, Peter Korsgaard

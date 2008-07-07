From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Mon, 07 Jul 2008 10:52:16 -0700
Message-ID: <487257D0.2030006@hp.com>
References: <1215178035.10393.763.camel@pmac.infradead.org>	<486E2818.1060003@garzik.org>	<20080704142753.27848ff8@lxorguk.ukuu.org.uk> <20080704.134329.209642254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, jeff@garzik.org, dwmw2@infradead.org,
	andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:46234 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbYGGRwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 13:52:23 -0400
In-Reply-To: <20080704.134329.209642254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Date: Fri, 4 Jul 2008 14:27:53 +0100
> 
> 
>>There are good sound reasons for having a firmware tree, the fact tg3 is
>>a bit of dinosaur in this area doesn't make it wrong.
> 
> 
> And bnx2, and bnx2x, and e100's ucode (hope David caught that one!).
> 
> It isn't just tg3.

Ah bnx2 - it may be "fixed" now, but trying to install Debian Lenny on a 
system with "core" bnx2 driven interfaces has been "fun" for a while now 
thanks to the firmware being exiled.

rick jones

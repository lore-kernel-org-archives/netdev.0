From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Sun, 22 Jul 2012 17:40:27 -0700 (PDT)
Message-ID: <20120722.174027.512678171338049935.davem@davemloft.net>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	<20120722.145454.943592825984584407.davem@davemloft.net>
	<CABF+-6XVWpaw6zQe2XNaz4y3oj-KdDm63vbut5jAxs3RWRC6LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kgroeneveld@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767Ab2GWAk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 20:40:27 -0400
In-Reply-To: <CABF+-6XVWpaw6zQe2XNaz4y3oj-KdDm63vbut5jAxs3RWRC6LQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Groeneveld <kgroeneveld@gmail.com>
Date: Sun, 22 Jul 2012 20:32:26 -0400

> On Sun, Jul 22, 2012 at 5:54 PM, David Miller <davem@davemloft.net> wrote:
>> From: Kevin Groeneveld <kgroeneveld@gmail.com>
>> Date: Sun, 22 Jul 2012 16:19:56 -0400
>>
>>> Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
>>
>> I don't see this as being very practical nor justified.
> 
> It is obviously not up to me to decide what is practical or justified
> in this case.  I am just always annoyed when I log into my Linksys
> router and check the network stats for my PPP interface and have no
> idea how many times the transfer stats have rolled over at 4GB.

I guess that's a good point.

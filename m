From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 03 Aug 2010 11:03:21 +0200
Message-ID: <287257a8aadbeea2a7bb5e57b855dd2d@localhost>
References: <20100802110334.GK11110@cel.leo>
 <20100802201629.GA5973@nuttenaction>
 <20100802.221813.43045517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <leonerd@leonerd.org.uk>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:56432 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754686Ab0HCJDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 05:03:22 -0400
In-Reply-To: <20100802.221813.43045517.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 02 Aug 2010 22:18:13 -0700 (PDT), David Miller wrote:



> Oh yeah, what is an iteration in your definition?  See this is why I

> totally refuse to add a looping construct to BPF.

> 

> If you just check for a single loop hitting, the user will just use

> a chaining of two looping constructs.  And then three levels of

> indirection, then four, etc.  He can run up to just before exhasting

> the "iteration limit" of one loop, and branch to the next one, and

> so on and so forth.



I am aware of any problems caused by complex instructions. David, I was

rather curious to see an unrecognized and ground breaking instructions, I

don't wanted to scotch any (possible) improvement.



HGN

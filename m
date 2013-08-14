From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Wed, 14 Aug 2013 12:06:57 +0200
Message-ID: <20130814100657.GB16264@order.stressinduktion.org>
References: <190D21D2-F86E-46D2-93E8-3050F57FE622@inf-net.nl> <20130813.011550.791636011692333018.davem@davemloft.net> <AFA62E3B-313C-4ECD-BA28-3543635136EE@inf-net.nl> <20130814.005506.502334877600106930.davem@davemloft.net> <F11B8118-B74D-4AA5-B899-0F2C8D33AA29@inf-net.nl> <64621FDB-9618-40A7-82EE-6056156580F6@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50745 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab3HNKG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 06:06:59 -0400
Content-Disposition: inline
In-Reply-To: <64621FDB-9618-40A7-82EE-6056156580F6@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 10:06:23AM +0200, Teco Boot wrote:
> Many excuses to send before adding text. Hitted wrong button.
> 
> I don't want to enforce something. Nor I want to spam. Nor I want to bypass. I just spend some cycles to get IPv6 with multi-homing work as designed. Subtrees was broken, maybe from day one. I'm glad there is progress.
> 
> I also do not want broken fixes in stable. I know what it is. As I posed, I had to deal with broken fixes when testing the subtree fix. I double checked the fix Hannes made, because Hannes asked me to do so. I'm in for doing more work here.

Teco, I don't see the problem. The patch is on its way. It is in stable and
will be included in the next kernel, 3.11. That is all the luxus a patch can
possibly have.

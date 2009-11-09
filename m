From: Andi Kleen <andi@firstfloor.org>
Subject: Re: query: net-next section mismatch(es)
Date: Mon, 09 Nov 2009 11:32:21 +0100
Message-ID: <87k4y056q2.fsf@basil.nowhere.org>
References: <4AF6D1F5.80307@gmail.com>
	<20091108.163527.185100796.davem@davemloft.net>
	<4AF777FC.4080805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:47973 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbZKIKcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 05:32:20 -0500
In-Reply-To: <4AF777FC.4080805@gmail.com> (William Allen Simpson's message of "Sun, 08 Nov 2009 21:01:32 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson <william.allen.simpson@gmail.com> writes:
>
>
> But I did it with 'make vmlinux' anyway, still makes no sense to me:

You should report those to the respective maintainers of the code that throws
the warning (see MAINTAINERS) and to linux-kernel. This is not really related
to networking.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

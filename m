From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Sat, 01 Oct 2011 14:16:05 -0400
Message-ID: <6.2.5.6.2.20111001141002.05af4b20@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.binnacle.cx ([74.95.187.105]:59618 "EHLO mx.binnacle.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691Ab1JASTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Oct 2011 14:19:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At 08:44 AM 10/1/2011 +0200, Eric Dumazet wrote:
>In my experience, I have the exact opposite :
>performance greatly improved in recent
>kernels. Unless you compile your kernel to include
>new features that might reduce performance
>(namespaces, cgroup, ...)

RH has both of the above turned on in the
2.6.32-71.29.1.el6.x86_64 kernel tested.

If these are big negatives to network
performance, could you list what should
specifically turned off to maximize
results?  Also a recommendation for
the best recent kernel for another
benchmark would be helpful.

Probably can't convince anyone to deploy a
kernel without commercial support, but if
an alternate compile fixes performance it
might be possible to convince RH to support
the alternative build.

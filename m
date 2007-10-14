From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [PATCH 00/14] Transparent Proxying Patches, Take 5
Date: Sun, 14 Oct 2007 11:05:16 +0200
Message-ID: <200710141105.16873@nessa>
References: <20071013172857.22517.84760.stgit@nessa.odu>
 <20071013.154408.74749737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:37691 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651AbXJNJGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Oct 2007 05:06:34 -0400
Received: from ip6-localhost ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPW00BWZ96W8V40@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sun, 14 Oct 2007 11:04:09 +0200 (CEST)
In-reply-to: <20071013.154408.74749737.davem@davemloft.net>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Sunday 14 October 2007, David Miller wrote:
> From: KOVACS Krisztian <hidden@sch.bme.hu>
> Date: Sat, 13 Oct 2007 19:28:57 +0200
>
> > This is the fifth round of transparent proxying patches following
> > recent discussion on netfilter-devel [1,2].
> >
> > The aim of the patchset is to make non-locally bound sockets work
> > both for receiving and sending. The target is IPv4 TCP/UDP at the
> > moment.
>
> I appreciate the submission, but the 2.6.25 merge window is so far
> away that I'm personally not really going to look seriously into any
> non-trivial new work like this until we sort out all the regressions
> we've already added this week for the 2.6.24 merge window :-)

Sure, definitely makes sense. I'll resend these once things have settled 
down with 2.4.24.

-- 
 KOVACS Krisztian

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] Transparent Proxying Patches, Take 5
Date: Sat, 13 Oct 2007 15:44:08 -0700 (PDT)
Message-ID: <20071013.154408.74749737.davem@davemloft.net>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753533AbXJMWoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 18:44:07 -0400
In-Reply-To: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Sat, 13 Oct 2007 19:28:57 +0200

> This is the fifth round of transparent proxying patches following
> recent discussion on netfilter-devel [1,2].
> 
> The aim of the patchset is to make non-locally bound sockets work both
> for receiving and sending. The target is IPv4 TCP/UDP at the moment.

I appreciate the submission, but the 2.6.25 merge window is so far
away that I'm personally not really going to look seriously into any
non-trivial new work like this until we sort out all the regressions
we've already added this week for the 2.6.24 merge window :-)

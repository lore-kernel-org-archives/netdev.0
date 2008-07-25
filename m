From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [RESEND] [iproute2/tc] add generic size table for
 qdiscs
Date: Fri, 25 Jul 2008 08:53:04 -0700
Message-ID: <20080725085304.6bfb5303@extreme>
References: <20080725131909.14497.2315.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45064 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751160AbYGYPxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 11:53:24 -0400
In-Reply-To: <20080725131909.14497.2315.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jul 2008 16:19:09 +0300
Jussi Kivilinna <jussi.kivilinna@mbnet.fi> wrote:

> Patch adds generic size table that is similiar to rate table, with
> difference that size table stores link layer packet size.
> 
> Based on patch by Patrick McHardy
>  http://marc.info/?l=linux-netdev&m=115201979221729&w=2
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

No need to resend. I always hold iproute2 patches until any kernel
components are accepted upstream.

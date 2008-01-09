From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 5/6][NETFILTER] Switch to using ctl_paths in
 nf_queue and conntrack modules
Date: Wed, 09 Jan 2008 00:33:18 -0800 (PST)
Message-ID: <20080109.003318.190390701.davem@davemloft.net>
References: <47839C30.2040402@openvz.org>
	<4783A00D.7000008@openvz.org>
	<4783A092.1040605@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57257
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751424AbYAIIdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:33:19 -0500
In-Reply-To: <4783A092.1040605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Jan 2008 17:10:58 +0100

> Pavel Emelyanov wrote:
> > This includes the most simple cases for netfilter.
> > 
> > The first part is tne queue modules for ipv4 and ipv6,
> > on which the net/ipv4/ and net/ipv6/ paths are reused 
> > from the appropriate ipv4 and ipv6 code.
> > 
> > The conntrack module is also patched, but this hunk is 
> > very small and simple.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Looks good to me.

Applied.

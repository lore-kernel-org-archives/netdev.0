From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.25 5/6][NETFILTER] Switch to using ctl_paths in
 nf_queue and conntrack modules
Date: Tue, 08 Jan 2008 17:10:58 +0100
Message-ID: <4783A092.1040605@trash.net>
References: <47839C30.2040402@openvz.org> <4783A00D.7000008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63641 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761062AbYAHQO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 11:14:57 -0500
In-Reply-To: <4783A00D.7000008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> This includes the most simple cases for netfilter.
> 
> The first part is tne queue modules for ipv4 and ipv6,
> on which the net/ipv4/ and net/ipv6/ paths are reused 
> from the appropriate ipv4 and ipv6 code.
> 
> The conntrack module is also patched, but this hunk is 
> very small and simple.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>


Looks good to me.

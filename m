From: Patrick McHardy <kaber@trash.net>
Subject: Re: nf-next-2.6.git
Date: Tue, 28 Oct 2008 17:29:40 +0100
Message-ID: <49073DF4.20503@trash.net>
References: <49070504.1010005@trash.net> <1225211021.5269.146.camel@localhost> <alpine.LNX.1.10.0810281227200.2281@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35795 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbYJ1Q3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 12:29:42 -0400
In-Reply-To: <alpine.LNX.1.10.0810281227200.2281@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Tuesday 2008-10-28 12:23, Joe Perches wrote:
> 
>> On Tue, 2008-10-28 at 13:26 +0100, Patrick McHardy wrote:
>>> Since Dave has created his net-next-2.6.git tree, I'm now also
>>> taking netfilter patches for 2.6.29. The nf-next-2.6.git tree
>>> is located at:
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
>> Should either or both of git trees be added to
>> MAINTAINERS: NETFILTER/IPTABLES/IPCHAINS?
> 
> No. This tree may disappears or reset at times.

It won't reset anymore. at least not if avoidable at all. But it will
disappear while the networking merge window is closed.



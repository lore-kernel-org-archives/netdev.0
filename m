From: jamal <hadi@cyberus.ca>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 09:07:33 -0500
Message-ID: <1295359653.2066.11.camel@mojatatu>
References: <4D336050.9030602@netfilter.org>
	 <20110118093811.GA7520@ff.dom.local>
	 <20110118.020702.115924992.davem@davemloft.net>
	 <20110118102437.GB7520@ff.dom.local>  <1295359503.2066.10.camel@mojatatu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:63204 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab1AROHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 09:07:34 -0500
Received: by qyj19 with SMTP id 19so3219284qyj.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 06:07:33 -0800 (PST)
In-Reply-To: <1295359503.2066.10.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-18 at 09:05 -0500, jamal wrote:
> On Tue, 2011-01-18 at 10:24 +0000, Jarek Poplawski wrote:
> 
> > Do you all expect all users manage to upgrade avahi app before
> > changing their stable kernel? I mean "own distro" users especially.
> 
> Unfortunately if that app is widely deployed, it is not pragmatic
> to break it in the name of pedanticity. 

And to complete that thought - if avahi continues to work and merely
whines, i dont see why this patch should be reverted..

cheers,
jamal



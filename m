From: jamal <hadi@cyberus.ca>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 09:05:03 -0500
Message-ID: <1295359503.2066.10.camel@mojatatu>
References: <4D336050.9030602@netfilter.org>
	 <20110118093811.GA7520@ff.dom.local>
	 <20110118.020702.115924992.davem@davemloft.net>
	 <20110118102437.GB7520@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	arthur.marsh@internode.on.net, jengelh@medozas.de,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65086 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab1AROFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 09:05:03 -0500
Received: by iyj18 with SMTP id 18so5718370iyj.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 06:05:03 -0800 (PST)
In-Reply-To: <20110118102437.GB7520@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-18 at 10:24 +0000, Jarek Poplawski wrote:

> Do you all expect all users manage to upgrade avahi app before
> changing their stable kernel? I mean "own distro" users especially.

Unfortunately if that app is widely deployed, it is not pragmatic
to break it in the name of pedanticity. i.e.
Be conservative in what you send (clearly Avahi is farting all over the
place) but more importantly be a nice liberal in what you accept.
Maybe tell them if you have the cycles about their bad behavior.
The important part is the GET (kind = 2). The DUMP as Jarek says
is merely a utility to extrapolate that we need you to
get everything.. So it is not such a big deal if someone passes
extraneous senseless flags. Wrong? yes.

Jarek - For the record although i coauthored the doc, I was merely
a messenger in putting together some artist painting.

cheers,
jamal


From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: critic on documentation of the network stack
Date: Fri, 24 Jan 2014 04:23:24 +0100
Message-ID: <20140124032324.GO7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33795 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaAXDXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 22:23:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

After net-next is closed I wanted to put the following link here:

  <http://linux.slashdot.org/comments.pl?sid=4356053&cid=45184693>

I don't want to start a flamefest or come too close to someone but I
fear some of the critic is reasonable.  Maybe we can do better (I have
to admit, I also hate writing documentation, e.g. have not yet send the
IP_PMTUDISC_INTERFACE man-page patches).

I try to start with some constructive discussion:

There are some great features in the network stack that some people miss
because of lack documentation. One possible solution is documentation
directly in the kernel, but mostly this is just written as a reference
and the real wonderful stuff is only achieved by putting lots of those
features correclty together.

Maybe this is the second or third time this was proposed but I'll try
again: Would it make sense to just start slow and setup a wiki where we
just throw in the various snippets we use for testing while developing
patches, maybe with a bit of background information? This may well attract
interested people outside of netdev@ which could start helping cleaning
up the wiki or add more useful documentation on their own. We could
check from time to time what could be fed back into Documentation/? The
reason why I would definitely help to improve the wiki is because I
am sure I can learn from other setups and testing methodologies, too,
and definitely still have not yet seen everything what is possible with
the linux network stack.

Thanks && Hopes for a constructive dicussion,

  Hannes

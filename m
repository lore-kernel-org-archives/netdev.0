From: Martin Josefsson <gandalf@mjufs.se>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 7 Oct 2008 15:16:44 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0810071510230.2675@wlug.westbo.se>
References: <20081006202401.14f03be2@speedy> <200810071520.56610.denys@visp.net.lb>
 <20081007124820.GG4606@ntm.vs.lam.cz> <200810071549.16647.denys@visp.net.lb>
 <48EB5C63.60501@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Milan Kocian <milon@wq.cz>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host91-201.netintact.se ([194.153.91.201]:32921 "EHLO
	wlug.westbo.se" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbYJGNpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 09:45:51 -0400
In-Reply-To: <48EB5C63.60501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Oct 2008, Patrick McHardy wrote:

>>> # ip l a l eth0 type vlan id 100

> It would be better to have -d as a default, I was afraid of breaking
> scripts of people sedding and awking around with the iproute output.

It would also be good to have a help text describing 'ip l a' as
'ip l h' doesn't mention it at all in at least iproute2-ss080725 which 
seems to be the latest release.

Until there's an easy accessible help text I'll stick to vconfig :)
I know the iproute help texts aren't always that easy to read but at least 
they beat getting:

# ip l a
RTNETLINK answers: Operation not supported

:)

/Martin

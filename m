From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux IPV6_SUBTREES not functioning
Date: Tue, 6 Aug 2013 10:53:07 +0200
Message-ID: <20130806085307.GD2941@order.stressinduktion.org>
References: <8CBF8819-E1D9-445E-9E7C-793422934733@inf-net.nl> <20130806083005.GC2941@order.stressinduktion.org> <013B2D02-AE77-4213-A929-3E35F9C9BF0F@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, boutier@pps.univ-paris-diderot.fr
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33991 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab3HFIxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 04:53:08 -0400
Content-Disposition: inline
In-Reply-To: <013B2D02-AE77-4213-A929-3E35F9C9BF0F@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 10:46:43AM +0200, Teco Boot wrote:
> Hi Hannes,
> 
> Yes problems with real traffic, with CORE (open source mobile ad hoc network emulator currently maintained by NRL and Boeing).
> Mattieu had same problems and therefore stepped to the ip rule. Most, if not all, take this ip rule hack. But then, for each and every source prefix a complete routing table is needed. This is a bad thing and shall be avoided.
> 
> Do you think it should work? Have it working? If so, I want to reproduce.

Definitely, that should work. I can reproduce the same output with your
script on net-next and am looking how to fix this. This could take a
bit because I have another patch in my pipeline for testing. But maybe
it is just a nit. ;)

Thanks,

  Hannes

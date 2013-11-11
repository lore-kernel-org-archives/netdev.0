From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next RFC 0/2] ipv6: allow temporary address
 management for user-created addresses
Date: Mon, 11 Nov 2013 18:03:02 -0500 (EST)
Message-ID: <20131111.180302.121736785883262610.davem@davemloft.net>
References: <20131111194901.GA2397@minipsycho.orion>
	<20131111.150152.1112137216301137879.davem@davemloft.net>
	<20131111210404.GB2397@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab3KKXDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 18:03:07 -0500
In-Reply-To: <20131111210404.GB2397@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 11 Nov 2013 22:04:04 +0100

> Anyway, should I touch the state in netdev patchwork or should I always
> leave that to you?
> 
> I'm used to set "changes requested" before I send another patch version
> and "RFC" when I send RFC patch.

I'd rather others not touch the patchwork state.

You plan to send this again, so whether it's marked RFC or changes requested
is not all that important :-)

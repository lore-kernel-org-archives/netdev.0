From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 06:09:23 -0700
Message-ID: <1383052163.5464.28.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028.204306.2213130677400093266.davem@davemloft.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com>
	 <20131029124010.GA15762@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>, jiri@resnulli.us,
	vyasevich@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org,
	Dave Taht <dave.taht@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:52020 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109Ab3J2NJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 09:09:25 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so8511030pdj.13
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 06:09:25 -0700 (PDT)
In-Reply-To: <20131029124010.GA15762@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 13:40 +0100, Hannes Frederic Sowa wrote:

> Yes, this is a very unfortunate situation. From my experience it is not that
> easy to get a patch merged into isc-dhcp.
> 
> It seems not that invasive to switch from af_packet to an udp socket with
> SO_BROADCAST set.

Has anyone cooked and submitted such a patch ?

I can visit ISC with a hammer if needed ;)

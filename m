From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: sit: update mtu check to take care of gso packets
Date: Tue, 17 Dec 2013 21:19:30 +0100
Message-ID: <20131217201930.GA27460@order.stressinduktion.org>
References: <52AB322B.7030802@redhat.com> <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34485 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab3LQUTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:19:31 -0500
Content-Disposition: inline
In-Reply-To: <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric!

On Mon, Dec 16, 2013 at 06:31:23AM -0800, Eric Dumazet wrote:
> In the future, we probably want to extend the MTU check to do the
> right thing for GSO packets...

How could that look like?

Greetings,

  Hannes

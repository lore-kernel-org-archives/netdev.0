From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Wed, 30 Oct 2013 21:07:25 +0100
Message-ID: <20131030200725.GB9093@order.stressinduktion.org>
References: <20131026201158.GI15744@order.stressinduktion.org> <20131029.000844.1092862708536984032.davem@davemloft.net> <20131029120424.GD26185@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39516 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab3J3UH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:07:27 -0400
Content-Disposition: inline
In-Reply-To: <20131029120424.GD26185@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Tue, Oct 29, 2013 at 01:04:25PM +0100, Hannes Frederic Sowa wrote:
> I really tried hard to find alternatives or even a way to enable
> the protection automatically given that at least unbound does apply
> IP_PMTUDISC_DONT to its sockets already. These are the reasons why I
> came up with the new IP_PMTUDISC_INTERFACE value:

Sorry to bother you but I would really love to hear your feedback on my
reasoning so I can try to come up with a solution you would be happy with.

Thank you,

  Hannes

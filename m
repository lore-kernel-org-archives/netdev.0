From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Wed, 28 Apr 2010 20:00:16 -0400
Message-ID: <1272499216.4258.123.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:46636 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755587Ab0D2AAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 20:00:21 -0400
Received: by qyk9 with SMTP id 9so22116184qyk.1
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 17:00:20 -0700 (PDT)
In-Reply-To: <1272498293.4258.121.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-28 at 19:45 -0400, jamal wrote:

> Your patch has improved the performance of rps relative to what is in
> net-next very lightly; but it has also improved the performance of
> non-rps;->

Correction: Last part of sentence not true (obvious if you look at
results i attached)

cheers,
jamal



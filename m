From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Tue, 17 Mar 2009 16:16:52 +0100
Message-ID: <49BFBEE4.9070405@cosmosbay.com>
References: <49B4B909.7050002@cosmosbay.com>	 <20090313.145152.121603300.davem@davemloft.net>	 <49BADE87.40407@cosmosbay.com>	 <20090313.153851.11725991.davem@davemloft.net>	 <49BED109.3020504@cosmosbay.com> <1237284716.5189.284.camel@laptop> <49BF84C0.2000808@cosmosbay.com> <49BFBAF1.3020607@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48884 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbZCQPSg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 11:18:36 -0400
In-Reply-To: <49BFBAF1.3020607@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Bloniarz a =E9crit :
> Eric Dumazet wrote:
>> Sure, I should have taken more time, will repost this in a couple of
>> hours,
>> with nice CHangelogs and split patches.
>=20
> One small thing: with CONFIG_IPV6=3Dm, inet_def_readable needs to be
> exported,
> right?
>=20

Absolutely, thank you !


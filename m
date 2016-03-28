From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 13:15:54 -0700
Message-ID: <56F990FA.9030307@hpe.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
 <1458944964-12890-3-git-send-email-edumazet@google.com>
 <56F95884.8010901@hpe.com>
 <1459184434.6473.104.camel@edumazet-glaptop3.roam.corp.google.com>
 <56F97B70.1000904@hpe.com>
 <1459191346.6473.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <56F981D7.2050801@hpe.com>
 <1459195293.6473.118.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:16032 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbcC1UP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 16:15:56 -0400
In-Reply-To: <1459195293.6473.118.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2016 01:01 PM, Eric Dumazet wrote:
> Note : file structures got RCU freeing back in 2.6.14, and I do not
> think named users ever complained about added cost ;)

Couldn't see the tree for the forest I guess :)

rick

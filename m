From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v3 net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 22:29:12 -0500
Message-ID: <87h9tq99mf.fsf@x220.int.ebiederm.org>
References: <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426114608.11398.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426125194.11398.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.215553.1544350193194225837.davem@davemloft.net>
	<1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	salo@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36297 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbCLDcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:32:53 -0400
In-Reply-To: <1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 11 Mar 2015 19:54:23 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2015-03-11 at 21:55 -0400, David Miller wrote:
>
>> Oh, even better, I'll push this one actually.
>> 
>
> I'll send an update, because I broke the build when CONFIG_NET_NS=n
>
> Or maybe we should adapt/push Eric patch 2/8 (net: Introduce
> possible_net_t)

Yeah that would make the kind of mistake that broke the build difficult.

> Eric, do you mind if I respin your patch, or do you prefer to do this
> yourself ?

Give me a minute and I will send an updated version of my first two
patches.

Eric

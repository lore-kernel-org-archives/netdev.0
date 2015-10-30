From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 0/4] net: clean up interactions of
 CHECKSUM_PARTIAL and fragmentation
Date: Fri, 30 Oct 2015 13:21:48 +0100
Message-ID: <1446207708.726564.424548761.49DD71DE@webmail.messagingengine.com>
References: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
 <87wpu7bamv.fsf@stressinduktion.org>
 <20151030.193748.1337418825359803374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vyasevich@gmail.com,
	bcodding@redhat.com, tom@herbertland.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:58143 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750882AbbJ3MVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 08:21:49 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 163B62096F
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 08:21:49 -0400 (EDT)
In-Reply-To: <20151030.193748.1337418825359803374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Oct 30, 2015, at 11:37, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 28 Oct 2015 10:33:28 +0100
> 
> > Those patches are actually for net and not for net-next,
> > sorry. Guess I messed it up with Ctrl-R foo.
> 
> Ok, in that case since:
> 
> 1) I already have a pull request pending (which is only delayed because
>    of you, hehe :-)

Next time I send those patches anonymously through the controversial
tree. :]
Sorry...

> 2) 4.3 is likely to be finalized on Sunday.
> 
> 3) I am getting on a plane first thing tomorrow morning.
> 
> I think this will end up going via the upcoming merge window and queud
> up for -stable.
> 
> Just FYI...

Totally fine by me. I think those people using nfs over udp with
fragmentation can wait a little bit longer.

Have a nice flight,
Hannes

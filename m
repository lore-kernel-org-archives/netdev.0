From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/8] ipv6: a bit more typesafety
Date: Sun, 21 Sep 2014 12:08:20 +0200
Message-ID: <1411294100.3376466.169937701.2E73D7E5@webmail.messagingengine.com>
References: <cover.1411249633.git.hannes@stressinduktion.org>
 <fab79c190ca6d2b728a2bacb30c234c0f054e76b.1411249633.git.hannes@stressinduktion.org>
 <541E344E.4040500@yoshifuji.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43173 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750752AbaIUKIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 06:08:21 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 62FB2205DC
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 06:08:20 -0400 (EDT)
In-Reply-To: <541E344E.4040500@yoshifuji.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, Sep 21, 2014, at 04:13, YOSHIFUJI Hideaki wrote:
> Hannes Frederic Sowa wrote:
> > Convert bool to bool and fib6_walker_t.state to the already existing enum.
> 
> Do you mean "boolean" variable (or member/type) to bool?

I meant to say I convert the prune member/argument type to bool. Will
fix it up.

Thanks,
Hannes

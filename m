From: synapse <synapse@hippy.csoma.elte.hu>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Mon, 08 Aug 2011 15:08:49 +0200
Message-ID: <4E3FDFE1.5070803@hippy.csoma.elte.hu>
References: <20110729.081902.300678107767426313.davem@davemloft.net>	<1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<1312002053.2873.41.camel@edumazet-laptop> <20110803.033442.1456080508068739176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:49212 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753821Ab1HHNJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 09:09:03 -0400
In-Reply-To: <20110803.033442.1456080508068739176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/11 12:34, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Sat, 30 Jul 2011 07:00:53 +0200
>
>> [PATCH] net: fix NULL dereferences in check_peer_redir()
> I'm adding this now to my tree so it gets more widespread
> testing.
>
> Thanks Eric.
So far, so good. The machine is alive and well ever since.

Thanks for your fast response.

Gergely Kalman

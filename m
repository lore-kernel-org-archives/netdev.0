From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 21:59:01 -0500
Message-ID: <52ABC975.2070308@mojatatu.com>
References: <52AB7ECB.30702@mojatatu.com>	<CAM_iQpXBGouT+rj=QscwtiNCGdnNi=mJq4Df7xbkgygnMQEEMg@mail.gmail.com>	<52AB87EB.6040508@mojatatu.com> <20131213.182325.2234215963739207753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, David.Laight@aculab.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:65279 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012Ab3LNC7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 21:59:04 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so4004385iec.19
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 18:59:03 -0800 (PST)
In-Reply-To: <20131213.182325.2234215963739207753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/13 18:23, David Miller wrote:

> Jamal, nobody implements this interface, therefore these extra
> stats are _NEVER_ provided.
 >
> This is the end of the discussion, when there are in-tree users
> of this method you can add it back.

Dave, I think that would be a good arguement if the feature was being
provided in a new set of patches today.
I dont see this as any different than removing an something from a UAPI 
header nobody knows any user of.

cheers,
jamal

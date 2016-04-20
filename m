From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: Split SW RX dropped counter per RX
 ring
Date: Wed, 20 Apr 2016 18:00:51 +0300
Message-ID: <571799A3.402@mellanox.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
 <1461157278-18528-5-git-send-email-ogerlitz@mellanox.com>
 <1461164209.10638.262.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eran Ben Elisha" <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	"Saeed Mahameed" <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0061.outbound.protection.outlook.com ([157.55.234.61]:19104
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751811AbcDTPRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 11:17:04 -0400
In-Reply-To: <1461164209.10638.262.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/2016 5:56 PM, Eric Dumazet wrote:
>> >Fixes: a3333b35da16 ('net/mlx4_en: Moderate ethtool callback to [...] ')
>> >Signed-off-by: Eran Ben Elisha<eranbe@mellanox.com>
>> >Reported-by: Brenden Blanco<bblanco@plumgrid.com>
>> >Signed-off-by: Saeed Mahameed<saeedm@mellanox.com>
>> >Signed-off-by: Or Gerlitz<ogerlitz@mellanox.com>
>> >---
> Reported-by: Eric Dumazet<edumazet@google.com>
>
> (http://www.spinics.net/lists/netdev/msg371318.html  )

Hi Eric,

Just to be sure, you'd like me to re-spin this and fix the reporter name?

>
> Thanks for following up !

sure

Or.

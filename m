From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] vlan: updates vlan real_num_tx_queues
Date: Wed, 24 Mar 2010 11:11:57 -0700 (PDT)
Message-ID: <20100324.111157.46329609.davem@davemloft.net>
References: <20100324004116.31609.73183.stgit@localhost.localdomain>
	<20100324004204.31609.55285.stgit@localhost.localdomain>
	<1269413047.2915.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, vasu.dev@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756657Ab0CXSLd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 14:11:33 -0400
In-Reply-To: <1269413047.2915.98.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Mar 2010 07:44:07 +0100

> Le mardi 23 mars 2010 =E0 17:42 -0700, Jeff Kirsher a =E9crit :
>> From: Vasu Dev <vasu.dev@intel.com>
>>=20
>> Updates real_num_tx_queues in case underlying real device
>> has changed real_num_tx_queues.
>>=20
>> -v2
>>  As per Eric Dumazet<eric.dumazet@gmail.com> comment:-
>>    -- adds BUG_ON to catch case of real_num_tx_queues exceeding num_=
tx_queues.
>>    -- created this self contained patch to just update real_num_tx_q=
ueues.
>>=20
>> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>=20
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

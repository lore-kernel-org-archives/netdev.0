From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH net-next] igb: Add support for byte queue limits.
Date: Wed, 21 Dec 2011 21:17:58 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B626011AB6@ORSMSX102.amr.corp.intel.com>
References: <1324480695.2301.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111221.144207.1402252938319338463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5988 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753885Ab1LUVSA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 16:18:00 -0500
In-Reply-To: <20111221.144207.1402252938319338463.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of David Miller
>Sent: Wednesday, December 21, 2011 11:42 AM
>To: eric.dumazet@gmail.com
>Cc: netdev@vger.kernel.org; Kirsher, Jeffrey T; Duyck, Alexander H
>Subject: Re: [PATCH net-next] igb: Add support for byte queue limits.
>
>From: Eric Dumazet <eric.dumazet@gmail.com>
>Date: Wed, 21 Dec 2011 16:18:15 +0100
>
>> This adds support for byte queue limits (BQL)
>>
>> Since this driver collects bytes count in 'bytecount' field, use it
>also
>> in igb_tx_map()
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> CC: Alexander Duyck <alexander.h.duyck@intel.com>
>
>Intel folks, you got this?
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Yes, although many are out for the holidays. 

ACK.  We'll get it into our queue for testing.

Thanks,

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation

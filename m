From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] can: sja1000: allow shared interrupt
 definition
Date: Sun, 21 Mar 2010 20:36:52 -0700 (PDT)
Message-ID: <20100321.203652.212382299.davem@davemloft.net>
References: <4BA3565F.6040907@visionsystems.de>
	<4BA356A4.5040205@visionsystems.de>
	<4BA37868.5040303@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yegor_sub1@visionsystems.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52894
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753711Ab0CVDga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:36:30 -0400
In-Reply-To: <4BA37868.5040303@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Fri, 19 Mar 2010 14:13:12 +0100

> Yegor Yefremov wrote:
>> SJA1000: allow shared interrupt definition
>> 
>> extend the AND mask, so that IRQF_SHARED flag remains
>> 
>> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
> 
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied.

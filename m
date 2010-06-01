From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: mpc5xxx_can.c: Fix build failure
Date: Tue, 01 Jun 2010 00:11:38 -0700 (PDT)
Message-ID: <20100601.001138.52175104.davem@davemloft.net>
References: <1275323499-15543-1-git-send-email-agust@denx.de>
	<4C03FF75.3010208@grandegger.com>
	<4C04A6C2.2090705@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agust@denx.de, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, grant.likely@secretlab.ca
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42958
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752843Ab0FAHL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:11:29 -0400
In-Reply-To: <4C04A6C2.2090705@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Tue, 01 Jun 2010 08:20:50 +0200

> On 05/31/2010 08:27 PM, Wolfgang Grandegger wrote:
>> Hi Anatolij,
>> 
>> On 05/31/2010 06:31 PM, Anatolij Gustschin wrote:
>>> Fixes build error caused by the OF device_node pointer
>>> being moved into struct device.
>>>
>>> Signed-off-by: Anatolij Gustschin <agust@denx.de>
>>> Cc: Wolfgang Grandegger <wg@grandegger.com>
>>> Cc: Grant Likely <grant.likely@secretlab.ca>
> 
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks.

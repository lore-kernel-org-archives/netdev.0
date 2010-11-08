From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: Fix rds message leak in rds_message_map_pages
Date: Mon, 08 Nov 2010 12:20:26 -0800 (PST)
Message-ID: <20101108.122026.59687113.davem@davemloft.net>
References: <4CD82362.9070402@parallels.com>
	<4CD85245.9090409@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43070
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475Ab0KHUUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:20:02 -0500
In-Reply-To: <4CD85245.9090409@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Grover <andy.grover@oracle.com>
Date: Mon, 08 Nov 2010 11:40:53 -0800

> On 11/08/2010 08:20 AM, Pavel Emelyanov wrote:
>> The sgs allocation error path leaks the allocated message.
>>
>> Signed-off-by: Pavel Emelyanov<xemul@openvz.org>
 ...
> Acked-by: Andy Grover <andy.grover@oracle.com>

Applied, thanks.

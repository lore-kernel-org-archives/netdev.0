From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] seq_file: add RCU versions of new hlist/list
 iterators (v3)
Date: Mon, 22 Feb 2010 15:46:13 -0800 (PST)
Message-ID: <20100222.154613.42870210.davem@davemloft.net>
References: <20100222175716.900955428@vyatta.com>
	<20100222175742.601785018@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750953Ab0BVXp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:45:56 -0500
In-Reply-To: <20100222175742.601785018@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 22 Feb 2010 09:57:17 -0800

> Many usages of seq_file use RCU protected lists, so non RCU
> iterators will not work safely.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

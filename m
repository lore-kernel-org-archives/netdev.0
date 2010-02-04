From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: Remove net_device_stats from
 bonding struct
Date: Wed, 03 Feb 2010 20:33:35 -0800 (PST)
Message-ID: <20100203.203335.247040869.davem@davemloft.net>
References: <20100202000648.GA30286@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33146
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220Ab0BDEdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:33:22 -0500
In-Reply-To: <20100202000648.GA30286@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Tue, 2 Feb 2010 05:36:52 +0530

> There is no need to maintain stats in the bonding structure.
> Use the instance of net_device_stats in netdevice.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] netdev: Use default implementation of
 ethtool_ops::get_link where possible
Date: Fri, 10 Dec 2010 15:56:05 -0800 (PST)
Message-ID: <20101210.155605.184847741.davem@davemloft.net>
References: <1291932625.2647.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48108
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755362Ab0LJXzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:55:38 -0500
In-Reply-To: <1291932625.2647.34.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 09 Dec 2010 22:10:25 +0000

> Various drivers are using implementations of ethtool_ops::get_link
> that are equivalent to the default ethtool_op_get_link().  Change
> them to use that instead.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

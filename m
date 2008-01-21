From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_atm: style cleanup
Date: Mon, 21 Jan 2008 02:25:37 -0800 (PST)
Message-ID: <20080121.022537.194419773.davem@davemloft.net>
References: <20080120140342.13139be7@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932070AbYAUKZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:25:32 -0500
In-Reply-To: <20080120140342.13139be7@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 20 Jan 2008 14:03:42 -0800

> ATM scheduler clean house:
>   * get rid of printk and qdisc_priv() wrapper
>   * split some assignment in if() statements
>   * whitespace and line breaks.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

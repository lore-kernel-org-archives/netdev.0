From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from
 veth_newlink()
Date: Mon, 24 Jan 2011 23:18:29 -0800 (PST)
Message-ID: <20110124.231829.189688816.davem@davemloft.net>
References: <20110124154546.GA2689@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751680Ab1AYHRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 02:17:54 -0500
In-Reply-To: <20110124154546.GA2689@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 24 Jan 2011 16:45:46 +0100

> The code is not needed because tb[IFLA_IFNAME] is already
> processed in rtnl_newlink(). Remove this redundancy.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks Jiri.

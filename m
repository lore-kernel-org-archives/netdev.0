From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139too: allow to set mac address on running device
Date: Fri, 13 Mar 2009 11:48:26 -0700 (PDT)
Message-ID: <20090313.114826.227438034.davem@davemloft.net>
References: <20090313175834.GE3436@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ivecera@redhat.com,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38880
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754526AbZCMSsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 14:48:40 -0400
In-Reply-To: <20090313175834.GE3436@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 13 Mar 2009 18:58:35 +0100

> Similar patch as for 8139cp posted yesterday, so the same comment:
> 
> So far there was not a chance to set a mac address on running 8139too device.
> This is for example needed when you want to use this NIC as a bonding slave in
> bonding device in mode balance-alb. This simple patch allows it.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Also applied, thanks.

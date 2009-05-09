From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: check retval of dev_addr_init()
Date: Sat, 09 May 2009 13:18:45 -0700 (PDT)
Message-ID: <20090509.131845.94369863.davem@davemloft.net>
References: <20090508233016.GC4881@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59836
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754111AbZEIUSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:18:49 -0400
In-Reply-To: <20090508233016.GC4881@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 9 May 2009 01:30:17 +0200

> Add missed checking of dev_addr_init return value in alloc_netdev_mq.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.

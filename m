From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: disallow to use net_assign_generic
 externally
Date: Tue, 27 Apr 2010 15:49:18 -0700 (PDT)
Message-ID: <20100427.154918.45129593.davem@davemloft.net>
References: <20100423114046.GC2853@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757362Ab0D0WtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:49:13 -0400
In-Reply-To: <20100423114046.GC2853@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 23 Apr 2010 13:40:47 +0200

> Now there's no need to use this fuction directly because it's handled by
> register_pernet_device. So to make this simple and easy to understand,
> make this static to do not tempt potentional users.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Looks reasonable, applied thanks Jiri.

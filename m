From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pppoe: use phonet_pernet instead of
 directly net_generic
Date: Mon, 26 Apr 2010 11:17:47 -0700 (PDT)
Message-ID: <20100426.111747.115930051.davem@davemloft.net>
References: <20100426134100.GF2941@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57333
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753349Ab0DZSRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:17:41 -0400
In-Reply-To: <20100426134100.GF2941@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 26 Apr 2010 15:41:00 +0200

> As in for example pppoe introduce phonet_pernet and use it instead of calling
> net_generic directly.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, and I modified your commit header line slightly.  This isn't
a change to "pppoe: " but rather "phonet: " :-)

Thanks.

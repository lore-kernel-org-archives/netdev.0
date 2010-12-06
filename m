From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] af_packet: remove pgv.flags
Date: Mon, 06 Dec 2010 13:01:11 -0800 (PST)
Message-ID: <20101206.130111.102564065.davem@davemloft.net>
References: <1291207977-17176-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jpirko@redhat.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753373Ab0LFVAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:00:43 -0500
In-Reply-To: <1291207977-17176-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed,  1 Dec 2010 20:52:57 +0800

> As we can check if an address is vmalloc address with is_vmalloc_addr(),
> we remove pgv.flags. Then we may get more pg_vecs.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.

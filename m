From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] make some netfilter globals __read_mostly
Date: Tue, 19 Sep 2006 15:39:14 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609191539050.20084@d.namei>
References: <4510461A.9060700@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:55239 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751993AbWISTjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:39:16 -0400
To: Brian Haley <brian.haley@hp.com>
In-Reply-To: <4510461A.9060700@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Sep 2006, Brian Haley wrote:

> Make some netfilter globals __read_mostly at the request of Patrick McHardy.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

These look good to me.


-- 
James Morris
<jmorris@namei.org>

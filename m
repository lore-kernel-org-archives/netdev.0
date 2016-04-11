From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix incorrect type
Date: Mon, 11 Apr 2016 15:04:17 -0400 (EDT)
Message-ID: <20160411.150417.1567033036936911890.davem@davemloft.net>
References: <b870830205240e7eb0732ddfdaa6534ab061fb1c.1460387151.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbcDKTET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 15:04:19 -0400
In-Reply-To: <b870830205240e7eb0732ddfdaa6534ab061fb1c.1460387151.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon, 11 Apr 2016 17:06:08 +0200

> The protocol is 16bit, not 32bit.
> 
> Fixes: e1e5314de08ba ("vxlan: implement GPE")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.

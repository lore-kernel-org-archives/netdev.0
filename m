From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hp100: unmap memory on error path
Date: Mon, 02 Aug 2010 16:08:55 -0700 (PDT)
Message-ID: <20100802.160855.214222892.davem@davemloft.net>
References: <20100730090604.GY26313@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: perex@perex.cz, jpirko@redhat.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753810Ab0HBXIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:08:37 -0400
In-Reply-To: <20100730090604.GY26313@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 30 Jul 2010 11:06:04 +0200

> There was an error path where "mem_ptr_virt" didn't get unmapped.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.

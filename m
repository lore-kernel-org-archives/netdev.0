From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kmalloc+memset -> kzalloc in frag_alloc_queue
Date: Mon, 15 Oct 2007 12:53:27 -0700 (PDT)
Message-ID: <20071015.125327.53355196.davem@davemloft.net>
References: <20071015144841.GA1009@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759236AbXJOTxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 15:53:23 -0400
In-Reply-To: <20071015144841.GA1009@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon, 15 Oct 2007 18:48:41 +0400

> kmalloc + memset -> kzalloc in frag_alloc_queue
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks!

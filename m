From: David Miller <davem@davemloft.net>
Subject: Re: Please pull 'p54' branch of wireless-2.6
Date: Wed, 19 Sep 2007 14:12:00 -0700 (PDT)
Message-ID: <20070919.141200.56568833.davem@davemloft.net>
References: <20070919195527.GD5483@tuxdriver.com>
	<20070919210405.GA2231@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, flamingice@sourmilk.net
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750965AbXISVMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 17:12:01 -0400
In-Reply-To: <20070919210405.GA2231@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 19 Sep 2007 22:04:05 +0100

> PLease put it into a separate subdirectory, thanks.
> 
> Also net2280.h seems rather oddly named.

The next time I rebase I'll try to take care of this for both
this driver and the iwlwifi stuff.

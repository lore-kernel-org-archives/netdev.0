From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/7] jme: Some minor coding style consistency
 modifications
Date: Mon, 06 Jul 2009 12:23:43 -0700 (PDT)
Message-ID: <20090706.122343.92724827.davem@davemloft.net>
References: <20090706145548.9CCA5122E3@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33584
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651AbZGFTXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 15:23:36 -0400
In-Reply-To: <20090706145548.9CCA5122E3@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Date: Mon, 6 Jul 2009 22:36:30 +0800

> Making coding style more consistent.
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

For the second time in a row.

Coding style cleanups are absolutely not appropriate for
net-2.6 at this time.  Such changes should be targetted
for net-next-2.6 only.

I'm, again, ignoring this entire patch series.

Split this up and target the patches properly.

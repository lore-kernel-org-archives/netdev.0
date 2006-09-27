From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Wed, 27 Sep 2006 16:21:57 -0700 (PDT)
Message-ID: <20060927.162157.111205399.davem@davemloft.net>
References: <20060926115910.GV18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kim.nordlund@nokia.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30851
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031243AbWI0XV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:21:58 -0400
To: tgraf@suug.ch
In-Reply-To: <20060926115910.GV18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 26 Sep 2006 13:59:10 +0200

> Prevents filters from being added if the first generated
> handle already exists.
> 
> Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, I'll push this to -stable too.

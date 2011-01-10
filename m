From: David Miller <davem@davemloft.net>
Subject: Re: [patch] phonet: some signedness bugs
Date: Sun, 09 Jan 2011 16:45:48 -0800 (PST)
Message-ID: <20110109.164548.58428218.davem@davemloft.net>
References: <20110107203755.GB1959@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, dan.j.rosenberg@gmail.com
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43874
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751945Ab1AJApR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 19:45:17 -0500
In-Reply-To: <20110107203755.GB1959@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 7 Jan 2011 23:37:55 +0300

> Dan Rosenberg pointed out that there were some signed comparison bugs
> in the phonet protocol.
> 
> http://marc.info/?l=full-disclosure&m=129424528425330&w=2
> 
> If you have already have CAP_SYS_ADMIN then you could use the bugs to
> get root, or someone could cause an oops by mistake.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied and queued up for -stable, thanks Dan.

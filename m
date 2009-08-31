From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert one non-symbolic return value in
 dev_queue_xmit
Date: Sun, 30 Aug 2009 22:18:13 -0700 (PDT)
Message-ID: <20090830.221813.130178817.davem@davemloft.net>
References: <20090830062136.6299.31696.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35464
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754277AbZHaFR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 01:17:59 -0400
In-Reply-To: <20090830062136.6299.31696.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Sun, 30 Aug 2009 11:51:36 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> net: convert remaining non-symbolic return values in dev_queue_xmit
> 
> Patch compiled and 32 simultaneous netperf testing ran fine. 
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied, but please do me a favor.

Do not provide two commit message header lines like this.
They aren't even equal.

Whatever you give me in the Subject line after "[....] " is what
ends up being the commit message header line when I apply your
patch.

Adding another commit header line in your email message body just
makes the commit look confusing and ugly.

So just give me one in the subject line and elide the one in the
message body.

Thanks.

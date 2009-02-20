From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc9420: fix another postfixed timeout
Date: Fri, 20 Feb 2009 00:36:31 -0800 (PST)
Message-ID: <20090220.003631.230433964.davem@davemloft.net>
References: <1234770366-3572-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roel.kluin@gmail.com,
	vlad.lyalikov@smsc.com, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33385
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753585AbZBTIgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:36:49 -0500
In-Reply-To: <1234770366-3572-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Mon, 16 Feb 2009 07:46:06 +0000

> Roel Kluin recently fixed several instances where variables reach -1,
> but 0 is tested afterwards.  This patch fixes another, so the timeout
> will be correctly detected and a warning printed.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.

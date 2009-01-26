From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: remove unused completion struct
Date: Sun, 25 Jan 2009 17:54:53 -0800 (PST)
Message-ID: <20090125.175453.175686552.davem@davemloft.net>
References: <1232463795-25665-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com, oliver@neukum.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45572
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751053AbZAZByv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 20:54:51 -0500
In-Reply-To: <1232463795-25665-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 20 Jan 2009 15:03:15 +0000

> Oliver Neukum spotted the useless complete() in our async callback.  On
> closer inspection, the entire completion struct is unused.  This patch
> removes it.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.

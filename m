From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Convert xtime.tv_sec to get_seconds()
Date: Fri, 02 Mar 2007 16:02:01 -0800 (PST)
Message-ID: <20070302.160201.59657151.davem@davemloft.net>
References: <Line.LNX.4.64.0702271622390.32168@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992779AbXCCACD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 19:02:03 -0500
In-Reply-To: <Line.LNX.4.64.0702271622390.32168@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Tue, 27 Feb 2007 16:24:49 -0500 (EST)

> Where appropriate, convert references to xtime.tv_sec to the
> get_seconds() helper function.
> 
> Signed-off-by: James Morris <jmorris@namei.org>

This looks great James, I'll apply it to net-2.6.2 once I set
that tree up.

Thanks again.

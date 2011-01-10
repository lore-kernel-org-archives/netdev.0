From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tlan: Use pr_fmt, pr_<level> and netdev_<level>,
 remove changelog
Date: Sun, 09 Jan 2011 23:39:50 -0800 (PST)
Message-ID: <20110109.233950.71582613.davem@davemloft.net>
References: <4D260ED0.5040301@iki.fi>
	<1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
	<1294354088.12561.295.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sakari.ailus@iki.fi, netdev@vger.kernel.org, chessman@tux.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750965Ab1AJHjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 02:39:18 -0500
In-Reply-To: <1294354088.12561.295.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 06 Jan 2011 14:48:08 -0800

> Neatening and standardization to the standard logging mechanisms.
> The changelog isn't useful anymore.
> Miscellaneous speen/speed typo correction.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This patch didn't apply cleanly to the current sources.

And anyways, please resubmit this once 2.6.38-rc1 is out and I
start taking net-next-2.6 patches again.

Thanks Joe.

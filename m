From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] tlan: add suspend/resume support
Date: Mon, 24 Jan 2011 15:07:28 -0800 (PST)
Message-ID: <20110124.150728.246519223.davem@davemloft.net>
References: <4D39F3A7.9050106@iki.fi>
	<1295643571-21216-1-git-send-email-sakari.ailus@iki.fi>
	<1295643571-21216-2-git-send-email-sakari.ailus@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chessman@tux.org, joe@perches.com
To: sakari.ailus@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753082Ab1AXXGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:06:53 -0500
In-Reply-To: <1295643571-21216-2-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sakari Ailus <sakari.ailus@iki.fi>
Date: Fri, 21 Jan 2011 22:59:31 +0200

> Add suspend/resume support to tlan driver. This allows not unloading the
> driver over suspend/resume.
> 
> Also, start (or now, wake) the queue after resetting the adapter --- not the
> other way around.
> 
> Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>

Applied.

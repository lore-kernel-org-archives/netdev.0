From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] typhoon: replace users of __constant_{endian}
Date: Sun, 18 Jan 2009 22:03:10 -0800 (PST)
Message-ID: <20090118.220310.122867092.davem@davemloft.net>
References: <1232066488.11986.5.camel@brick>
	<1232075884.1502.0.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, jeff@garzik.org, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755650AbZASGDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 01:03:12 -0500
In-Reply-To: <1232075884.1502.0.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Thu, 15 Jan 2009 22:18:04 -0500

> On Thu, 2009-01-15 at 16:41 -0800, Harvey Harrison wrote:
> > The base versions handle constant folding just fine, use them
> > directly.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Acked-by: David Dillow <dave@thedillows.org>

Applied for 2.6.30, thanks everyone.

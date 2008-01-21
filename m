From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] bonding: 7 fixes for 2.6.24
Date: Sun, 20 Jan 2008 19:58:09 -0800 (PST)
Message-ID: <20080120.195809.100169968.davem@davemloft.net>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
	<20080120.171538.12566715.davem@davemloft.net>
	<20080120173644.4586483e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	andy@greyhouse.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50660
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755795AbYAUD6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 22:58:04 -0500
In-Reply-To: <20080120173644.4586483e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sun, 20 Jan 2008 17:36:44 -0800

> On Sun, 20 Jan 2008 17:15:38 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> 
> > From: Jay Vosburgh <fubar@us.ibm.com>
> > Date: Thu, 17 Jan 2008 16:24:56 -0800
> > 
> > > 	Following are seven patches to fix locking problems,
> > > silence locking-related warnings and resolve one recent regression
> > > in the current 2.6.24-rc.
> > 
> > Jeff, are you going to merge this stuff in?
> > 
> > I'll drop that rtnl_lock() one-liner if so...
> 
> It's all in mainline.  The one-liner should be unneeded.

Excellent.

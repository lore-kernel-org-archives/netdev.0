From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv4 4/9] macb: convert printk to netdev_ and friends
Date: Wed, 9 Nov 2011 13:14:21 +0000
Message-ID: <20111109131421.GC4253@totoro>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
 <1320761613-18641-5-git-send-email-jamie@jamieiles.com>
 <1320844247.6923.18.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	arnd@arndb.de
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57382 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab1KINO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 08:14:26 -0500
Received: by eye27 with SMTP id 27so1410027eye.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 05:14:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1320844247.6923.18.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Wed, Nov 09, 2011 at 05:10:47AM -0800, Joe Perches wrote:
> On Tue, 2011-11-08 at 14:13 +0000, Jamie Iles wrote:
> > macb is already using the dev_dbg() and friends helpers so use netdev_()
> > along with a pr_fmt() definition to make the printing a little cleaner.
> trivia...

All valid comments.  I'll fix all of these up.

Thanks for taking a look!

Jamie

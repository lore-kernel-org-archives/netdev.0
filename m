From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/2] qcusbnet: Cleanups
Date: Fri, 01 Oct 2010 08:56:09 -0700
Message-ID: <1285948569.752.38.camel@Joe-Laptop>
References: <20100928171026.GB6083@google.com>
	 <cover.1285727642.git.joe@perches.com>
	 <20100930.173338.149831717.davem@davemloft.net>
	 <1285893935.10780.11.camel@Joe-Laptop>  <20101001144231.GC8632@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net, mjg59@srcf.ucam.org,
	jglasgow@google.com, msb@google.com, olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2613 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998Ab0JAP4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 11:56:11 -0400
In-Reply-To: <20101001144231.GC8632@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-01 at 10:42 -0400, Elly Jones wrote:
> On Thu, Sep 30, 2010 at 05:45:35PM -0700, Joe Perches wrote:
> > These cleanups are meant for Elly Jones on top
> > of the Qualcomm Gobi 2000 driver she submitted.
> Wow, thank you! I'll incorporate your fixes, make sure I have clean
> checkpatch output, and send a v2.

Hi Elly,

I wouldn't go overboard on checkpatch compliance.
I think you can ignore several messages.  I did.

Braces around single line statements are ok by me.
80+ column lines don't bother me much.

Probably the extern qcusbnet_debug should go into
some .h file though.

cheers, Joe


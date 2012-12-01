From: David Miller <davem@davemloft.net>
Subject: Re: respin of __dev* removal patches
Date: Fri, 30 Nov 2012 22:20:21 -0500 (EST)
Message-ID: <20121130.222021.1095074411846638107.davem@davemloft.net>
References: <20121130221555.2AA738019A@viridian.itc.virginia.edu>
	<20121130233947.GA17353@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfp5p@viridian.itc.virginia.edu, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab2LADUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 22:20:24 -0500
In-Reply-To: <20121130233947.GA17353@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 30 Nov 2012 15:39:47 -0800

> On Fri, Nov 30, 2012 at 05:15:54PM -0500, Bill Pemberton wrote:
>> I've got a respin of the hotplug removal patches for the networking
>> subsystem.  I don't want to irritate you like the big patch set did,
>> so before I submit them, what do you want to see that will keep your
>> pain to a minimum?
>> 
>> I've redone them so that all the __dev* removals are done at once so
>> there won't be one patch for __devinit, one for __devexit, etc.  I've
>> also broken them down into chunks following what's in the MAINTAINERS
>> file.  The result is 103 patches.
> 
> As that's a lot of patches to handle through patchwork, would it be
> easier for the network maintainers for me to just put these in a tree
> they can pull from?  I will base it off of net-next.

That might work.

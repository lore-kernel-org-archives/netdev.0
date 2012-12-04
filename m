From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] Remove __dev* markings from the networking drivers
Date: Tue, 04 Dec 2012 16:02:57 -0500 (EST)
Message-ID: <20121204.160257.680931337109544105.davem@davemloft.net>
References: <20121203.153623.958379034481583512.davem@davemloft.net>
	<20121204.131726.103739824056368439.davem@davemloft.net>
	<20121204203052.GB32674@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab2LDVDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 16:03:02 -0500
In-Reply-To: <20121204203052.GB32674@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 4 Dec 2012 12:30:52 -0800

> On Tue, Dec 04, 2012 at 01:17:26PM -0500, David Miller wrote:
>> It seemse the function declarations were not properly reformatted
>> after the __dev* tags were removed.  You can't just search and replace
>> this kind of stuff.  The result looks terrible.
>> 
>> Greg please check for things like this next time you send me changes
>> written by someone else.
> 
> Ick, sorry about that.  Want me to fix them all back up?  It's the least
> I could do.

If you could do that, I'd really appreciate it.

Thanks Greg.

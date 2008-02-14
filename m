From: tony_gibbs <Tony_Gibbs@compuserve.com>
Subject: Re: [PATCH] plusb.c patched to support Belkin F5U258 USB
  host-to-host cable
Date: Thu, 14 Feb 2008 16:55:52 -0500
Message-ID: <200802141656_MC3-1-FBCF-214A@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: tony_gibbs <100045.2745@compuserve.com>,
	Linux USB mailing list <majordomo@vger.kernel.org>,
	NETDEV mailing list <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liaag1aj.mx.compuserve.com ([149.174.40.37]:40809 "EHLO
	liaag1aj.mx.compuserve.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753077AbYBNV6I convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 16:58:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Dave,

Thanks for the reply.

I don't know why it arrived line-wrapped, and I thought I had turned DEBUG
off. So I need to try again on those.

What device name should be there? Just "PL-25A1"? or "Belkin F5U258"?

Yes I did get it to pass data back and forth, and I posted a message to
linux-usb list on Mon, 11 Feb 2008 15:34:34 -0800 showing the results.

So it is working ok, but I need to format the patch so that it will merge
in.

Thoughts?

Kind Regards,
        Tony

Message text written by David Brownell
> 
On Thursday 14 February 2008, tony_gibbs wrote:
> I have tried to make the changes I have been working on and testing with
> your help into a patch as attached.
> 
> Please let me know what you think of it.

It arrived line wrapped, and turned on debug options that
should stay off by default ... it couldn't merge, on those
bases alone.  Also, "PL-25A1hack" isn't a product name.  ;)

Did you get this to pass data back and forth yet?  The last
report I had from you was that it wouldn't pass data.  The
Prolific hardware tends to enter that mode after a while.
(Maybe there's documentation unseen by any Linux developer,
saying how to make those chips actually work...)  But you
reported that they didn't seem to work even when freshly
plugged in.

- Dave

<


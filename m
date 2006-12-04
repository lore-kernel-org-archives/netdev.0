From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][GENETLINK] introduce command names
Date: Mon, 04 Dec 2006 12:49:49 -0500
Message-ID: <1165254589.3643.32.camel@localhost>
References: <1165061496.3564.11.camel@localhost>
	 <20061204092857.GO8693@postel.suug.ch> <1165237742.3664.22.camel@localhost>
	 <20061204163451.GS8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:53645 "EHLO
	nz-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935370AbWLDRty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 12:49:54 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1915374nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 09:49:53 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061204163451.GS8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 17:34 +0100, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-12-04 08:09
> > Just makes the discovery more knowledgeable. 
...
...
> > It would be a lot more human friendly to put better readability in the
> > commands.
> 
> I don't agree to waste so much text section just to fancy up some
> userspace tool which is mainly a toy while developing. 

Hey, it is not a toy ;->

> If you
> really need it, do it in userspace like libnl.
...
....
> > That is the real agenda actually. To be honest i dont know how realistic
> > it would be. But one of the next things is to output the command
> > policies.
> 
> Once we go that path we can reconsider a patch based on this which
> includes the bits to dump the information to userspace. Until then
> I don't see the point in this.

Ok, fair enough lets defer it for then.

cheers,
jamal


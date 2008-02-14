From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] plusb.c patched to support Belkin F5U258 USB host-to-host cable
Date: Thu, 14 Feb 2008 13:20:28 -0800
Message-ID: <200802141320.28488.david-b@pacbell.net>
References: <200802141557_MC3-1-FBB3-3DA7@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NETDEV mailing list <netdev@vger.kernel.org>,
	Linux USB mailing list <majordomo@vger.kernel.org>
To: tony_gibbs <Tony_Gibbs@compuserve.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.sbc.mail.mud.yahoo.com ([68.142.198.208]:35603 "HELO
	smtp109.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932569AbYBNVUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 16:20:31 -0500
In-Reply-To: <200802141557_MC3-1-FBB3-3DA7@compuserve.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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




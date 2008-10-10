From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8169_get_stats seems to be adding random crap to
	rx_missed_errors count
Date: Fri, 10 Oct 2008 21:53:47 +0200
Message-ID: <20081010195347.GA22518@electric-eye.fr.zoreil.com>
References: <b2cdc9f30810100947s699dbc76ia72023b08e064816@mail.gmail.com> <20081010172731.GA19845@electric-eye.fr.zoreil.com> <20081010.114808.230313157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-hacker@bennee.com, lkml@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38030 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760356AbYJJTyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 15:54:01 -0400
Content-Disposition: inline
In-Reply-To: <20081010.114808.230313157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Francois, if you have all of this stuff fixed how come you haven't
> submitted these properly to netdev for inclusion?

I have submitted the bugfix part, it has been properly included in
Jeff's tree that was rejected as bad timed.

And, no, this stuff was not ready for the previous merge window.

> I asked you yesterday to make a patch submission to me so that your
> fixes get into the tree.

It will be done. Sorry if I am slower than you.

> But you just keep point people at your web site over and over again.

You are the very first one complaining about it.

> That doesn't work.

Give yourself a break (TM). It's friday.

-- 
Ueimor

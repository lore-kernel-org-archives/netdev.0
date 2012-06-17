From: Steven King <sfking@fdwdc.com>
Subject: Re: [PATCH] fec: fix clk handling for Coldfire.
Date: Sun, 17 Jun 2012 01:21:18 -0700
Message-ID: <201206170121.18807.sfking@fdwdc.com>
References: <201206170000.48076.sfking@fdwdc.com> <20120617.010849.1446855262442120268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm6.access.bullet.mail.mud.yahoo.com ([66.94.237.207]:48754
	"HELO nm6.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753424Ab2FQIVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 04:21:21 -0400
In-Reply-To: <20120617.010849.1446855262442120268.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 17 June 2012 1:08:49 am David Miller wrote:
> Sorry, I'm not going to allow you to crap up this driver with
> ifdefs.  Find a way to fix it without that.

Well, then how about then revert the commit and have the imx folks do whatever 
they need to do without breaking things for Coldfire?

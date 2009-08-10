From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/8] sky2: driver update
Date: Mon, 10 Aug 2009 08:48:22 -0700
Message-ID: <20090810084822.2df65a12@nehalam>
References: <20090806161213.148382653@vyatta.com>
	<20090809.210943.256633746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38476 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953AbZHJPs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2009 11:48:27 -0400
In-Reply-To: <20090809.210943.256633746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 09 Aug 2009 21:09:43 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 06 Aug 2009 09:12:13 -0700
> 
> > This undoes the prematurely committed sky2 transmit logic changes
> > and applies Mike's later changes.
> > Here is a corrected patch stream please apply this to 2.6.31-rc5
> 
> I have to pass on this set, too many problems:
> 
> 1) You didn't provide explicit "From: " lines for patches where
>    you were not the author Stephen.  I could guess from the
>    Signoff lines but I'd rather not.

What is the mechanics for this, does patchwork accept From:
lines in message body?

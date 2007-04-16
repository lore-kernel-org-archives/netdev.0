From: Willy Tarreau <w@1wt.eu>
Subject: Re: [IPv4] fib: Fix out of bound access of fib_props[]
Date: Mon, 16 Apr 2007 10:45:52 +0200
Message-ID: <20070416084552.GB3806@1wt.eu>
References: <20070324153435.GE521@postel.suug.ch> <20070324.203339.71087299.davem@davemloft.net> <20070414142655.GA21327@1wt.eu> <20070414154836.GA1758@1wt.eu> <20070416081417.GC521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1949 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965280AbXDPIp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 04:45:59 -0400
Content-Disposition: inline
In-Reply-To: <20070416081417.GC521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2007 at 10:14:17AM +0200, Thomas Graf wrote:
> * Willy Tarreau <w@1wt.eu> 2007-04-14 17:48
> > Finally, I think I have the correct fix below. Please someone confirm
> > or tell me I'm nuts.
> 
> Looks good, same is needed for DECnet

Thank you Thomas.
The DECnet stuff was already merged, it was (expectedly) the same code.

Regards,
Willy


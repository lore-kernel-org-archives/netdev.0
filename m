From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sat, 10 May 2008 23:08:56 -0700 (PDT)
Message-ID: <20080510.230856.193689901.davem@davemloft.net>
References: <48258074.7060306@krogh.cc>
	<20080510.213431.193696750.davem@davemloft.net>
	<482687B6.5070101@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753464AbYEKGJV@vger.kernel.org>
In-Reply-To: <482687B6.5070101@krogh.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Krogh <jesper@krogh.cc>
Date: Sun, 11 May 2008 07:44:22 +0200

> David Miller wrote:
> > From: Jesper Krogh <jesper@krogh.cc>
> > Date: Sat, 10 May 2008 13:01:08 +0200
> > 
> >> Any good suggestions about the "Transmit timed out" messages. It
> >> currently leads to a system that "doesnt die" but doesnt respond within
> >> 15 minutes of load of the network adapter.
> > 
> > It's likely some bug in the driver that hangs the card for whatever
> > reason, which we'll need to work out.
> 
> What can I do to help out? I'd really like to get the 10g interface
> operational quite soon.

I personally don't have the time to work on this currently, but maybe
I will later this week.

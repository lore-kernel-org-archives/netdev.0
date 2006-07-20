From: Piet Delaney <piet@bluelane.com>
Subject: Re: Alternate to Ixia's ANVL test harness for tcp compliance.
Date: Thu, 20 Jul 2006 14:42:57 -0700
Message-ID: <1153431778.15610.19.camel@piet2.bluelane.com>
References: <1153424967.8114.450.camel@piet2.bluelane.com>
	 <44BFE1D2.8060004@garzik.org>
	 <1153427074.8114.466.camel@piet2.bluelane.com>
	 <44BFF644.2020507@garzik.org>
Reply-To: piet@bluelane.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Piet Delaney <piet@bluelane.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	piet at work <piet@work.piet.net>,
	Rajneesh Saini <rksaini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mse2fe2.mse2.exchange.ms ([66.232.26.194]:27239 "EHLO
	mse2fe2.mse2.exchange.ms") by vger.kernel.org with ESMTP
	id S1030384AbWGTVnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 17:43:02 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44BFF644.2020507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-20 at 17:31 -0400, Jeff Garzik wrote:
> Piet Delaney wrote:
> > I wonder if Microsoft is providing the "big challenge" to porting the
> > same GUI to linux. The world really doesn't need yet another Java
> > language. Gosling is a Genius, I studied his X11 News Server enough
> > to know first hand. Microsoft lost in court with their violating the
> > Java standards and C sharp seems to be just another stratagy to their
> > bizarre attempt to world domination (Like the SCO mess).
> 
> Runtime dynamic bytecode languages -- Java, Perl, Python, Ruby, ... -- 
> do seem to be all the rage.
> 
> As DaveM noted, though, C# is fully supported under Linux.
> 
> Or maybe they could go for Gtk+, which has successfully been used to 
> maintain complex GUIs apps on both Windows and Linux.  GIMP is the most 
> notable example, but use of Gtk+, GLib, and mingw has meant that you can 
> build Linux-ish apps on Windows without nasty porting layers like Cygwin.

Perhaps, but my experience with GTK has been that it's difficult
to get installed right if you put it on /usr/local. I tried compiling
ethereal for our platform and it needed GTK and a series of other
libraries. I suspect it's likely a major effort to migrate from a
Microsoft C sharp environment to GTK.

-piet

> 
> 	Jeff
> 
> 
-- 
Piet Delaney
BlueLane Teck
W: (408) 200-5256; piet@bluelane.com
H: (408) 243-8872; piet@piet.net



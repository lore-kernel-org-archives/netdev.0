From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Alternate to Ixia's ANVL test harness for tcp compliance.
Date: Thu, 20 Jul 2006 17:31:48 -0400
Message-ID: <44BFF644.2020507@garzik.org>
References: <1153424967.8114.450.camel@piet2.bluelane.com>	 <44BFE1D2.8060004@garzik.org> <1153427074.8114.466.camel@piet2.bluelane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	piet at work <piet@work.piet.net>,
	Rajneesh Saini <rksaini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48054 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030377AbWGTVcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 17:32:43 -0400
To: piet@bluelane.com
In-Reply-To: <1153427074.8114.466.camel@piet2.bluelane.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Piet Delaney wrote:
> I wonder if Microsoft is providing the "big challenge" to porting the
> same GUI to linux. The world really doesn't need yet another Java
> language. Gosling is a Genius, I studied his X11 News Server enough
> to know first hand. Microsoft lost in court with their violating the
> Java standards and C sharp seems to be just another stratagy to their
> bizarre attempt to world domination (Like the SCO mess).

Runtime dynamic bytecode languages -- Java, Perl, Python, Ruby, ... -- 
do seem to be all the rage.

As DaveM noted, though, C# is fully supported under Linux.

Or maybe they could go for Gtk+, which has successfully been used to 
maintain complex GUIs apps on both Windows and Linux.  GIMP is the most 
notable example, but use of Gtk+, GLib, and mingw has meant that you can 
build Linux-ish apps on Windows without nasty porting layers like Cygwin.

	Jeff



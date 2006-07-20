From: Piet Delaney <piet@bluelane.com>
Subject: Re: Alternate to Ixia's ANVL test harness for tcp compliance.
Date: Thu, 20 Jul 2006 13:24:34 -0700
Message-ID: <1153427074.8114.466.camel@piet2.bluelane.com>
References: <1153424967.8114.450.camel@piet2.bluelane.com>
	 <44BFE1D2.8060004@garzik.org>
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
Received: from mse2fe2.mse2.exchange.ms ([66.232.26.194]:35539 "EHLO
	mse2fe2.mse2.exchange.ms") by vger.kernel.org with ESMTP
	id S964890AbWGTUYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 16:24:38 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44BFE1D2.8060004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-20 at 16:04 -0400, Jeff Garzik wrote:
> Piet Delaney wrote:
> > Do any of you use tools other than ANVL for RFC compliance while
> > hacking to the tcp code?
> > 
> > In the unlikely event that there isn't an alternate; is there any
> > interest in a netdev group effort to motivate Ixia to porting their C 
> > sharp code to linux. I get the feeling that come of their developers
> > would like to port the code to linux.
> 
> 
> Linux is the most RFC-compliant net stack in the world...  if they don't 
> want to support Linux, it's their loss.  :)

They aren't exactly dropping support for Linux, they 'just' are not 
plaining to port the new ethereal like GUI to Lunux:
------------------------------------------------------------------------------
Hi Piet,

Unfortunately there is no plan to redesign the GUI for Linux. We added
support for Windows a couple of releases back. The latest release 7.10
has been benefit by a new Windows GUI framework we have designed for all
windows based Ixia test application. The new GUI is based on C#, which
includes ethereal like packet decode, ladder diagram, Outlook like GUI
design. Currently there is big challenge to implement the same GUI for
Linux. The needed resource is also an issue. Ixia will continue to
maintain and support Linux platform. Please rest assure. Both windows
and linux platforms share the same under layer test engine.. So there is
no difference in test cases. Ixia also offers an upgrade path from Linux
to Windows. Please contact your local Ixia sales if you are interested.
Dean
-------------------------------------------------------------------------------

I wonder if Microsoft is providing the "big challenge" to porting the
same GUI to linux. The world really doesn't need yet another Java
language. Gosling is a Genius, I studied his X11 News Server enough
to know first hand. Microsoft lost in court with their violating the
Java standards and C sharp seems to be just another stratagy to their
bizarre attempt to world domination (Like the SCO mess).

I suggest that Linux networking companies like UNM and us be Beta
customers for a port. So far it hasn't been entertained TMBK.
 
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



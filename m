From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: Fri, 31 Dec 2004 12:26:05 +0100
Message-ID: <20041231112605.GF32419@postel.suug.ch>
References: <41D3785F.3040909@trash.net> <1104382562.1048.39.camel@jzny.localdomain> <41D3F5EC.9050808@trash.net> <41D4286B.1060106@trash.net> <1104468336.1048.205.camel@jzny.localdomain> <41D521EA.2090603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41D521EA.2090603@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41D521EA.2090603@trash.net> 2004-12-31 10:54
> jamal wrote:
> 
> >Ok, sounds like a good plan (gives me more time to work with the driver
> >stuff which is getting out of control ;->): I think the patches may have
> >goten a little messy. Maybe the order should be: you, Thomas with what
> >he has now then myself with eaction and Thomas with extended matches (I
> >dont think the order of the last two matters). I will just code against
> >whatever latest release is and migrate later when all the otehr patches
> >are in.
> 
> Sounds good too me.

Fine with me. Jamal, we might want to share some code to do the logic
relations like sharing the macros to access the bits, checking if the
the current result already makes the whole expression obvious etc.

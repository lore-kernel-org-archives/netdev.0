From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: 31 Dec 2004 10:00:50 -0500
Message-ID: <1104505249.1049.266.camel@jzny.localdomain>
References: <41D3785F.3040909@trash.net>
	 <1104382562.1048.39.camel@jzny.localdomain> <41D3F5EC.9050808@trash.net>
	 <41D4286B.1060106@trash.net> <1104468336.1048.205.camel@jzny.localdomain>
	 <41D521EA.2090603@trash.net>  <20041231112605.GF32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041231112605.GF32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-31 at 06:26, Thomas Graf wrote:

>  Jamal, we might want to share some code to do the logic
> relations like sharing the macros to access the bits, checking if the
> the current result already makes the whole expression obvious etc.

Sure we can discuss - you may actually end up doing yours first and i
will use the LinuxWay(tm) ;-> aka inherit all your bugs ;->
I started working on it but too distracted finding some exciting stuff
on this e1000.

cheers,
jamal

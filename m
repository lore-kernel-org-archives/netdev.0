From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bug#656585: iproute: "ip l" fails with RTNETLINK message
Date: Fri, 20 Jan 2012 12:34:16 -0800
Message-ID: <20120120123416.238a1f55@nehalam.linuxnetplumber.net>
References: <20120120101233.17696.79723.reportbug@localhost>
	<20120120131047.GA7179@amd64.fatal.se>
	<20120120143922.GA20128@qemfd.net>
	<20120120145054.GA8443@amd64.fatal.se>
	<20120120165219.GA21936@qemfd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fatal.se>, netdev@vger.kernel.org
To: nick black <dankamongmen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33449 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376Ab2ATUeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 15:34:19 -0500
In-Reply-To: <20120120165219.GA21936@qemfd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2012 11:52:19 -0500
nick black <dankamongmen@gmail.com> wrote:

> Andreas Henriksson left as an exercise for the reader:
> > Hello again!
> > 
> > On Fri, Jan 20, 2012 at 09:39:22AM -0500, nick black wrote:
> > > I can put together a manpage patch if you'd like, but I suspect you'd rather
> > > I leave it in your capable hands.
> > 
> > I'd very much appreciate if you'd create a patch and submit it upstream
> > (Stephen Hemminger <shemminger@vyatta.com> and the netdev mailing list)
> > There are many other issues with the man pages and help output that
> > you are more then willing to help dig into if you have time.
> > Please see http://bugs.debian.org/src:iproute for hints on where
> > documentation updates are needed.
> 
> Alrightie, I did just that.
> 
> I'm in no position to write a full ip-l2tp(8) man page. I have, however:
> 
>  * synced SYNOPSIS up with current "ip help" entries
>  * made SYNOPSIS conform to "ip help"'s ordering
>  * synced SYNTAX up with SYNOPSIS, pulling definitions for netns and
>     ntable out from beyond the realms of my ass. please verify.
>  * alphabetized the SYNTAX entries
>  * synced SEE ALSO up with current "dpkg -L iproute | grep 8/ip-"
> 
> Attached and inline.

Ok, applied.

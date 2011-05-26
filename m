From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.11
Date: Thu, 26 May 2011 19:04:20 +0200
Message-ID: <4DDE8814.7090201@trash.net>
References: <4DDE857E.40807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org,
	"'netfilter@vger.kernel.org'" <netfilter
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DDE857E.40807@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 26.05.2011 18:53, schrieb Patrick McHardy:
> The netfilter coreteam presents:
> 
>     iptables version 1.4.10

That's supposed to read 1.4.11 of course :)

> 
> the iptables release for the 2.6.39 kernels. Due to some mistakes
> on my side we didn't have a release for longer than expected, so
> this contains a rather large number of changes.
> 
> Changes include:
> 
> - various bugfixes, cleanups and documentation updates
> 
> - a new "guided option parser" from Jan, replacing a lot of the
>   open-coded option parsing by a data driven parser
> 
> - support for the current SET target as contained in 2.6.39
> 
> - support for the new devgroup match
> 
> - support for the new AUDIT target
> 
> - support for a new NFQUEUE bypass option, allowing to bypass the
>   queue if no userspace listener is present
> 
> - a new iptables option "-C" to check for existance of a rules
> 
> - a new xtables-multi binary which supports both IPv4 and IPv6
> 
> See the attached changelogs for the full list of changes.
> 
> Version 1.4.11 can be obtained from:
> 
> http://www.netfilter.org/projects/iptables/downloads.html
> ftp://ftp.netfilter.org/pub/iptables/
> git://git.netfilter.org/iptables.git
> 
> On behalf of the Netfilter Core Team.
> Happy firewalling!


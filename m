From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: Tue, 7 Dec 2004 18:52:59 +0100
Message-ID: <20041207175259.GH1371@postel.suug.ch>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch> <1102386461.1093.26.camel@jzny.localdomain> <20041207124922.GA1371@postel.suug.ch> <1102424568.1089.120.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102424568.1089.120.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> BTW, did the gnet_stats patches to iproute2 ever get merged?
> If you have cycles, can you please look at that hang being reported
> using older tc with 2.6.10-rc3?

They're not in bk://developer.osdl.org/iproute2 so I guess not. I've put
a iproute2 including all my changes into a tarball at:
	http://people.suug.ch/~tgr/iproute2/iproute2-2.6.9-tgr.tar.gz

From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: 07 Dec 2004 08:20:18 -0500
Message-ID: <1102425618.1089.133.camel@jzny.localdomain>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch>
	 <1102386461.1093.26.camel@jzny.localdomain>
	 <20041207124922.GA1371@postel.suug.ch>
	 <1102424568.1089.120.camel@jzny.localdomain>
	 <20041207131706.GB1371@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041207131706.GB1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-07 at 08:17, Thomas Graf wrote:

> It's not really related to the gnet_stats code.  stats_lock isn't set
> in the action code when using an older iproute2. I haven't tested this
> case because it was marked as broken anyway. 

Can you ping my memory on this? Is this tc with initial support
for actions or something much older than that.

cheers,
jamal

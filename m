From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats in
	action	policer
Date: 19 Dec 2004 14:24:09 -0500
Message-ID: <1103484249.1046.143.camel@jzny.localdomain>
References: <20041215130128.GK8493@postel.suug.ch>
	 <1103119774.1077.74.camel@jzny.localdomain>  <41C05B60.6030504@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41C05B60.6030504@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 2004-12-15 at 10:42, Patrick McHardy wrote:

> I value regression testing, but I prefer to use my eyes first. 
> Since
> this problem is not related to the policer oops fix it doesn't
> convince me that my time would have been well invested doing the
> tests you described.

But it is _absolutely_ related to the policer oops.
If those tests were run to begin with there would be no oops neither
this latest problem. 
Hopefully with the regression tests in place this will get better.

[You fear Murphy less than i - and thats a style difference. Your style
is actually more effective in Linux because you can distribute the
burden onto users. As a matter of fact it is within Daves tolerance
range (but not mine[1]). So you should do just fine]

cheers,
jamal

[1]I am not saying anyone can write perfect code (Alexey was close;->),
but if there are known things to check for, such as those i proposed
(and have been checking on for a long time), trusting your eyes maybe
insufficient.

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH PKT_SCHED 0/22]: tc action cleanups
Date: Mon, 10 Jan 2005 22:21:04 +0100
Message-ID: <41E2F1C0.90505@trash.net>
References: <41E2D97A.1060400@trash.net> <1105391297.1084.54.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1105391297.1084.54.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Mon, 2005-01-10 at 14:37, Patrick McHardy wrote:
>
>>Hi Jamal,
>>
>>following are the reorganized tc action cleanup patches with some
>>additional fixes. Please review and comment, I would like to ask
>>Dave to pull them in soon so I don't get more clashes.
>>
>>
>
>Other than the ipt breakage fix - Is there anything new since our last
>discussion that you want me to pay attention to? 
>Sorry dont have the cycles to pay close attention today. Will do
>tommorow. 
>

There are a couple of new things, more noteable more action init fixes,
but nothing that needs special attention.

>You seem to also have touched some police code this time (I suppose the
>LinuxWay payoff time is here).So, if you want me to pay close attention
>to specific items i will; otherwise i would suggest that Dave sucks them
>in, then we can resolve things later.
>
The police fixes are basically the same as for the other actions.
Some more review can't hurt, but I think we can put them in now.

Dave, please pull in the changes from bk://212.42.230.204/net-2.6-sched

Regards
Patrick

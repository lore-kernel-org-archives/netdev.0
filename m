From: syrius.ml@no-log.org
Subject: Re: IMQ / new Dummy device post.
Date: Thu, 22 Apr 2004 19:43:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87oepjx65r.87n053x65r@87llknx65r.message.id>
References: <wazza.87ad18jbdl.fsf@message.id>
	<1082427350.1034.70.camel@jzny.localdomain>
	<wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	<wazza.87hdvddqxq.fsf@message.id>
	<1082639764.1059.81.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1082639764.1059.81.camel@jzny.localdomain> (hadi@cyberus.ca's
 message of "22 Apr 2004 09:16:04 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

It oops when using the ingress qdisc + action mirred egress redirect
filter on tun0. (no egress at all, no ingress on eth0)
It doesn't oops using an ingress qdisc + a simple police+drop filter
on tun0...

-- 

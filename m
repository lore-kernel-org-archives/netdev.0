From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Tue, 17 Feb 2004 19:10:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040217191011.012a749e.davem@redhat.com>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	<20040211200549.736fa8b3.davem@redhat.com>
	<1076561489.1032.65.camel@jzny.localdomain>
	<1076561998.1035.72.camel@jzny.localdomain>
	<1076562282.1033.76.camel@jzny.localdomain>
	<20040211211536.23e97997.davem@redhat.com>
	<1076563502.1031.85.camel@jzny.localdomain>
	<1076564638.1033.91.camel@jzny.localdomain>
	<20040211215142.7f817513.davem@redhat.com>
	<1076566176.1033.94.camel@jzny.localdomain>
	<20040211222259.776ad818.davem@redhat.com>
	<402D54D6.5070708@trash.net>
	<20040213213606.5a13cc76.davem@redhat.com>
	<1076762757.1060.4.camel@jzny.localdomain>
	<1076763997.1059.13.camel@jzny.localdomain>
	<1076766981.1059.16.camel@jzny.localdomain>
	<20040214124958.499294a6.davem@redhat.com>
	<402F4A2D.1070405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, qnex@atlantis.knm.org.pl, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <402F4A2D.1070405@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Feb 2004 11:30:05 +0100
Patrick McHardy <kaber@trash.net> wrote:

> I guess he meant something like this, but I still think it encourages
> broken configurations in combination with non-work-conserving
> schedulers.

Patrick, "(x || 1)" is not the same as "(x ? x : 1)"
:-)

Please make a new patch.

From: Steve Hill <steve@navaho.co.uk>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Tue, 16 Dec 2003 09:00:23 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312160859290.16778-100000@sorbus2.navaho>
References: <200312160843.58992.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312160843.58992.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Dec 2003, Bart De Schuymer wrote:

> Steve, does this patch fix things? Of course, first remove your code from
> ip_fragment.c. I haven't tested this patch yet, this will have to wait
> until this evening.

No, it still leaks I'm afraid :(

-- 

- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...

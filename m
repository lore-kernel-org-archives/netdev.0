From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.5.74 X.25+LAPB still kills the kernel
Date: Fri, 11 Jul 2003 22:44:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711224413.6aa70649.davem@redhat.com>
References: <m3y8z5dldr.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3y8z5dldr.fsf@defiant.pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 11 Jul 2003 19:27:28 +0200
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> No need to actually use X.25+LAPB, it's enough to just compile it in.

Hmmm, if nobody is listening on linux-x25 and neither is
the listed "MAINTAINER" eis@baty.hanse.de we should update
the linux/MAINTAINERS file to be in sync with reality.

Anyways, I'll try to look into this if nobody else does.

Thanks for reporting this to the right place finally, as
a reward your bug will be looked at and hopefully fixed.

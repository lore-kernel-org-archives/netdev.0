From: Peter Bieringer <pb@bieringer.de>
Subject: Re: Re: IPv6 enabled Network services
Date: Thu, 13 Feb 2003 09:59:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15100000.1045126774@gate.muc.bieringer.de>
References: <20030213085238.4096.qmail@webmail18.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030213085238.4096.qmail@webmail18.rediffmail.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Thursday, February 13, 2003 08:52:38 AM +0000 santosh kumar
gowda <ipv6_san@rediffmail.com> wrote:

> Hi Marc
> i tried for
> telnet> 3ffe::102:304:1234
> still i get
> 3ffe::102:304:1234: unknown host

Can you ping6 this address? Are the shown addresses configured in
real or are they rewritten for public ML posting?

They look a little bit strange to me.

Also try
$ telnet <ipv6address>

perhaps this kind will work.

If not, telnet has perhaps no IPv6 support (which version/RPM do you
use)? Check also 
$ which telnet
to be sure you're using the right one.

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/

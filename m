From: "David S. Miller" <davem@redhat.com>
Subject: Re: b44 driver in Linux 2.4.22
Date: Tue, 26 Aug 2003 02:25:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826022509.65ca3f4e.davem@redhat.com>
References: <Pine.LNX.4.55.0308260936140.17569@dodo>
	<20030826070055.GA19639@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dave.antliff@paradise.net.nz, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20030826070055.GA19639@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 26 Aug 2003 10:00:55 +0300
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> On Tue, Aug 26, 2003 at 09:38:45AM +1200, David Antliff wrote:
> > Also, just out of curiosity, is this driver based on Michael Chan's
> > Broadcom bcm4400 driver?
>
> Dave would know best since he wrote the beast, but I believe it's 
> written using bcm4400 as "documentation" and really based on the
> generic Linux ethernet driver template (so tg3.c with tg3 bits changed 
> into b44 bits :-) )

That's correct.

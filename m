From: anand@eis.iisc.ernet.in (SVR Anand)
Subject: Re: 2.6.0-test9-bk25 : bridge works fine
Date: Tue, 25 Nov 2003 22:51:21 +0530 (GMT+05:30)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311251721.WAA25695@eis.iisc.ernet.in>
References: <20031123152601.67646dc1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org (Linus Torvalds), linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20031123152601.67646dc1.davem@redhat.com> from "David S. Miller" at Nov 23, 2003 03:26:01 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

With test9-bk25, I am not facing any problem for the past many hours which
was not to be the case with test9. I am hopeful that it will work for ever.

Thanks a lot for all the help. Next time I should make it a point to try on 
the latest of the latest before shooting off a mail :)

Anand
> 
> On Sat, 22 Nov 2003 08:20:40 -0800 (PST)
> Linus Torvalds <torvalds@osdl.org> wrote:
> 
> > On Sat, 22 Nov 2003, SVR Anand wrote:
> > > 
> > > The problem is : After 3 to 4 hours of functioning, the bridge stops working 
> > > and the machine becomes unusable where it doesn't respond to keyboard, and 
> > > there is no video display.
> > 
> > Sounds like a memory leak somewhere. It would probably be interesting to 
> > watch /proc/slabinfo every five minutes or so, and see what happens..
> 
> Also, we've certainly fixed some serious networking bugs since test9
> came out.
> 

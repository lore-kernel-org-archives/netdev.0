From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Sun, 23 Nov 2003 15:26:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031123152601.67646dc1.davem@redhat.com>
References: <200311221527.UAA29684@eis.iisc.ernet.in>
	<Pine.LNX.4.44.0311220819260.2379-100000@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anand@eis.iisc.ernet.in, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0311220819260.2379-100000@home.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Nov 2003 08:20:40 -0800 (PST)
Linus Torvalds <torvalds@osdl.org> wrote:

> On Sat, 22 Nov 2003, SVR Anand wrote:
> > 
> > The problem is : After 3 to 4 hours of functioning, the bridge stops working 
> > and the machine becomes unusable where it doesn't respond to keyboard, and 
> > there is no video display.
> 
> Sounds like a memory leak somewhere. It would probably be interesting to 
> watch /proc/slabinfo every five minutes or so, and see what happens..

Also, we've certainly fixed some serious networking bugs since test9
came out.

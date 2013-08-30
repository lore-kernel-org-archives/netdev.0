From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/7] Drop support for Renesys H8/300 architecture
Date: Fri, 30 Aug 2013 12:37:40 -0700
Message-ID: <20130830193740.GA13101@roeck-us.net>
References: <1377880842-6835-1-git-send-email-linux@roeck-us.net>
 <20130830184611.GA27455@spo001.leaseweb.com>
 <20130830191146.GA12090@roeck-us.net>
 <CA+55aFyxHsKhtqqz9jTDYo89bCNqCWhjHGJ4HzFrHnJ0yxLXjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wim Van Sebroeck <wim@iguana.be>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	IDE-ML <linux-ide@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Watchdog Mailing List <linux-watchdog@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyxHsKhtqqz9jTDYo89bCNqCWhjHGJ4HzFrHnJ0yxLXjQ@mail.gmail.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 30, 2013 at 12:14:20PM -0700, Linus Torvalds wrote:
> On Fri, Aug 30, 2013 at 12:11 PM, Guenter Roeck <linux@roeck-us.net> wrote:
> >
> > I would not mind if Linus would agree to pull it right away for 3.12,
> > but that seems to be a bit on the fast side.
> 
> I'm ok with code deletion patches, I don't think that would be a
> problem. I didn't check them, but I assume this is all literally just
> removing code that is conditional on h8/300 config options?
> 
Yes.

I found a couple more since I sent the series, but nothing significant.

What is your preference - keep it until 3.13, or prepare it now and send you
a pull request for 3.12 ?

Thanks,
Guenter

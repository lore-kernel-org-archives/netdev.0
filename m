From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/7] Drop support for Renesys H8/300 architecture
Date: Fri, 30 Aug 2013 12:14:20 -0700
Message-ID: <CA+55aFyxHsKhtqqz9jTDYo89bCNqCWhjHGJ4HzFrHnJ0yxLXjQ@mail.gmail.com>
References: <1377880842-6835-1-git-send-email-linux@roeck-us.net>
	<20130830184611.GA27455@spo001.leaseweb.com>
	<20130830191146.GA12090@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130830191146.GA12090@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 30, 2013 at 12:11 PM, Guenter Roeck <linux@roeck-us.net> wrote:
>
> I would not mind if Linus would agree to pull it right away for 3.12,
> but that seems to be a bit on the fast side.

I'm ok with code deletion patches, I don't think that would be a
problem. I didn't check them, but I assume this is all literally just
removing code that is conditional on h8/300 config options?

              Linus

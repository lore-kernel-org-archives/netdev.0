From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] Make predictable/persistent network interface names more
 handy
Date: Sun, 11 Jan 2015 14:42:36 -0800
Message-ID: <20150111144236.1b693c93@urahara>
References: <1421009571-5279-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	john.fastabend@gmail.com, herbert@gondor.apana.org.au,
	vyasevic@redhat.com, jiri@resnulli.us, vfalico@gmail.com,
	therbert@google.com, edumazet@google.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org, kay@vrfy.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1421009571-5279-1-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 11 Jan 2015 21:52:48 +0100
Richard Weinberger <richard@nod.at> wrote:

> Since the Linux distribution of my choice makes use of
> predictable network interface names[0] my USB gadgets
> are no longer usb0 but enp0s29u1u2. Same for all other network devices.
> While I can fully understand that this new naming scheme makes sense
> for a lot of people and makes their work easier it does not really work for me.
> My brain is not able to remember that my Beaglebone's USB-Ethernet
> is now enp0s29u1u2. Even after looking at the output of ifconfig
> I have to copy&paste the interface name.
> Instead of just disabling the feature I thought about
> a generic solution which satisfies both needs.

Fix your distro. Easier said than done.
Current systemd names are much shorter

P.s:  ifconfig is deprecated.


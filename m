From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Autoconfig link-local address on ip6-ip6 tunnel
 device
Date: Sun, 30 Nov 2003 16:00:51 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311301559270.1231-100000@netcore.fi>
References: <20031129204701.37a06847.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ville Nuorvala <vnuorval@tcs.hut.fi>, <yoshfuji@linux-ipv6.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031129204701.37a06847.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Nov 2003, David S. Miller wrote:
> > Hi Dave, Yoshifuji-san is now ok with this patch :) Would you apply it?
> 
> I thought some more about this and I am realizing this is not
> a pure bug fix, I am very sure Linus will not take the change.
> 
> We can hold onto this until 2.6.1, ok?

Another perspective:

Well, the specs say very strongly that all interfaces MUST have
lik-local addresses, so it's a pretty big bug,
implementation-of-the-spec -wise.

However, it's probably not a bug in the current code, though.

But I'm personally fine with waiting..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Mon, 08 Apr 2013 22:14:15 -0700
Message-ID: <5163A3A7.7060701@schaufler-ca.com>
References: <6182509.cOVcY8B4g7@sifl> <1365479891.3887.99.camel@edumazet-glaptop> <5163992F.30406@schaufler-ca.com> <20130409.004144.1226810973846202358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pmoore@redhat.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130409.004144.1226810973846202358.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/8/2013 9:41 PM, David Miller wrote:
> It makes sure SYN/ACKs have a socket context attached to the
> packet, which only LSMs actually need.
>
> You participated in the thread where this stuff was discussed and the
> initial version of this patch was posted, so this patch, or any aspect
> of it, should not be a mystery.

I am flattered by your assumption that I can recall
on a moment's notice every thread I've been involved in since
1978. A reference to that thread would be mighty helpful.

The reality is that someone new to the thread is going to
have a bunch of trouble figuring out what you're talking
about. Every patch posting should have sufficient context
that someone who did not happen to see the background
threads will understand why it is being proposed.

I believe you when you say that I participated in the discussion.
I'll be dipped in caramel and rolled in nuts if I can find the
threads. Help me out by providing enough context that I can find
what I said, what you said, and if I still agree with myself.


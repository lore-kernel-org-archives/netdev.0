From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make XFRM optional
Date: Mon, 4 Aug 2003 16:51:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804165137.40d744c5.davem@redhat.com>
References: <20030804125022.GA8167@averell>
	<20030804.215801.124854897.yoshfuji@linux-ipv6.org>
	<20030804130408.GA36367@colin2.muc.de>
	<20030804114507.6e496c77.davem@redhat.com>
	<20030804203524.GA15874@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, ak@muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@colin2.muc.de>
In-Reply-To: <20030804203524.GA15874@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 4 Aug 2003 22:35:24 +0200
Andi Kleen <ak@colin2.muc.de> wrote:

> Ok, here is a new patch again current BKCVS. It also moves the inet_peer_idlock
> only inside netsyms.

This one is missing net/xfrm/xfrm_export.c :-(

Andi, please be more careful with your patches.  I'd suggest use
subversions or whatever source management system you like best to help
avoid these problems in the future.  You seem to be chronicly making
mistakes like this, as if you're rushing things.

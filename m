From: Willy Tarreau <willy@w.ods.org>
Subject: Re: Deadlock problem with dev->refcnt somewhere in netlink/multicast... [PATCH]
Date: Thu, 5 Feb 2004 19:21:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205182146.GA12703@alpha.home.local>
References: <OFDBAB37F5.227951E9-ON88256E2E.0080F5BF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com, Alexandre.Cassen@wanadoo.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFDBAB37F5.227951E9-ON88256E2E.0080F5BF@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, Feb 02, 2004 at 04:41:11PM -0700, David Stevens wrote:
> Below is a patch for the reference count problem you ran into.

I have just tested 2.4.25-rc1 (which includes your patch) right now, and I
cannot reproduce the problem anymore. So to me, the problem is closed.

Thanks for the fix !
Willy

From: Ralph Doncaster <ralph@istop.com>
Subject: Re: [Bonding-devel] Re: [RFC][bonding] Improve VLAN support on top
 of bonding
Date: Tue, 15 Jul 2003 14:36:10 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0307151434100.4590@ns.istop.com>
References: <Pine.LNX.4.44.0307151115500.6012-100000@sasami.anime.net>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Hollis <goemon@anime.net>
In-Reply-To: <Pine.LNX.4.44.0307151115500.6012-100000@sasami.anime.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003, Dan Hollis wrote:

> That is exactly what it does. hw tcp checksumming helps a LOT at gbe rates

This still doesn't make any sense.  The copy from user-space to kernel
space does the checksum as far as I recall (unless you use the
router-not-host kernel build option).

-Ralph

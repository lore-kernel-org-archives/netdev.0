From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Wed, 9 Jul 2003 11:28:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709152814.GC15293@gtf.org>
References: <Pine.LNX.4.44.0307091816280.1313-100000@hl.kauneta.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrius Kasparavicius <andrius@andrius.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307091816280.1313-100000@hl.kauneta.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 09, 2003 at 06:19:51PM +0300, Andrius Kasparavicius wrote:
> hello, as far as i know, currently there is no native vlan support in
> network device drivers. I mean, always need patching MTU.. add 4 bytes..
> :-(
> 
> is there any problems to include full vlans support?

Native VLAN support has been in the kernel for a while.

A few drivers still need patching, and unfortunately the VLAN driver
patches floating around all need cleaning up.

	Jeff

From: "Rask Ingemann Lambertsen" <rask@sygehus.dk>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Thu, 11 Sep 2003 15:57:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911145555.M56042@sygehus.dk>
References: <Pine.LNX.4.44.0307091816280.1313-100000@hl.kauneta.net> <20030709152814.GC15293@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030709152814.GC15293@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Jul 2003 11:28:15 -0400, Jeff Garzik wrote
> On Wed, Jul 09, 2003 at 06:19:51PM +0300, Andrius Kasparavicius wrote:
> > hello, as far as i know, currently there is no native vlan support in
> > network device drivers. I mean, always need patching MTU.. add 4 bytes..
[cut]
> A few drivers still need patching, and unfortunately the VLAN driver
> patches floating around all need cleaning up.

What does a network device driver need to do to ensure VLAN compatibility? Is 
it as simple as allocating buffer space for MTU + 4 bytes or is there more to 
it than that?

-- 
Regards,
Rask Ingemann Lambertsen

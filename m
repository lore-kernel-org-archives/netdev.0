From: Olaf Kirch <okir@suse.de>
Subject: Re: (usagi-users 03222) Re: support of IPv6 by NFS
Date: Tue, 1 Mar 2005 17:19:05 +0100
Message-ID: <20050301161905.GD22324@suse.de>
References: <42243F8D.5030302@bull.net> <200503010744.38339.Info@Quantum-Sci.com> <1109689712.17484.6.camel@firenze.zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com
To: Jeroen Massar <jeroen@unfix.org>
Content-Disposition: inline
In-Reply-To: <1109689712.17484.6.camel@firenze.zurich.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2005 at 04:08:32PM +0100, Jeroen Massar wrote:
> > There is no Linux 6to4 
> >UDP tunnelling app, but there should be, because this is such a common 
> >problem.  (As I understand, Teredo is Winduhs-only, and is not supported by 
> >most tunnel operators)
> 
> The protocol for Teredo is open and can be implemented at will:

Except that it's quite horrible, and it requires a centralized broker,
and IIRC it also makes assumptions about the way your NAT implementation
assigns ports.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

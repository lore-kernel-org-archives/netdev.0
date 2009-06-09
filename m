From: Steve.Glendinning-sdUf+H5yV5I@public.gmane.org
Subject: Re: [PATCH 1/2] netdev: smsc911x: allow
 building on Blackfin systems
Date: Tue, 9 Jun 2009 09:04:14 +0100
Message-ID: <OFFCE515A9.69B05047-ON802575D0.002BA8D0-802575D0.002C553B@smsc.com>
References: <8bd0f97a0906081450s6b471d30p56d86e31ba708730@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ian.Saturley-sdUf+H5yV5I@public.gmane.org
To: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <8bd0f97a0906081450s6b471d30p56d86e31ba708730-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote on 08/06/2009 22:50:32:
> On Mon, Jun 8, 2009 at 17:37, David Miller wrote:
> > So many devices are available for powerpc and sparc64 that will never
> > appear there, however those drivers now get build validated on those
> > platforms and it's therefore a net-win.
> 
> i run randconfigs nightly ... it's neat the kind of unlikely build bugs 
you find
> -mike

Sounds great, do you want to modify your patch to remove the line 
altogether?

Thanks,
Steve

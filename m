From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Thu, 27 May 2004 09:52:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526235255.GC5958@sgi.com>
References: <B1508D50A0692F42B217C22C02D849727FEDBE@NT-IRVA-0741.brcm.ad.broadcom.com> <20040526114714.23fcf37d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040526114714.23fcf37d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 26, 2004 at 11:47:14AM -0700, David S. Miller wrote:
> On Wed, 26 May 2004 10:43:10 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > I would recommend tg3 to make the switch also.
> 
> Ok, I'll make it use DMA tx descriptors by default.

Cool!

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

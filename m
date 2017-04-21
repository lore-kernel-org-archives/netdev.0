From: Rich Felker <dalias@libc.org>
Subject: Re: Re: [PATCH v2 0/3] uapi glibc compat: fix musl libc
 compatibility
Date: Fri, 21 Apr 2017 10:41:51 -0400
Message-ID: <20170421144151.GF17319@brightrain.aerifal.cx>
References: <20170418210036.26039-1-hauke@hauke-m.de>
 <20170420.160739.1263793303398330801.davem@davemloft.net>
 <1492719277.8404.16.camel@infradead.org>
 <20170420.163630.313375940241598525.davem@davemloft.net>
 <25477d46-b100-ce87-98d9-8c5e02d409b8@hauke-m.de>
Reply-To: musl@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
	maillist-linux@barfooze.de, mikko.rapeli@iki.fi,
	musl@lists.openwall.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <musl-return-11272-gllmg-musl=m.gmane.org@lists.openwall.com>
List-Post: <mailto:musl@lists.openwall.com>
List-Help: <mailto:musl-help@lists.openwall.com>
List-Unsubscribe: <mailto:musl-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:musl-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <25477d46-b100-ce87-98d9-8c5e02d409b8@hauke-m.de>
Sender: Rich Felker <dalias@aerifal.cx>
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2017 at 03:14:21PM +0200, Hauke Mehrtens wrote:
> 
> 
> On 04/20/2017 10:36 PM, David Miller wrote:
> > From: David Woodhouse <dwmw2@infradead.org>
> > Date: Thu, 20 Apr 2017 21:14:37 +0100
> > 
> >> I agree, except I don't think you're going far enough. Those "standard
> >> names" you mention... some of this stuff actually depends on __GLIBC__,
> >> and *that* isn't right either.
> > 
> > Yep, that's something that needs correcting.
> > 
> Should all libc implementations define __GLIBC__

Absolutely not.

Rich

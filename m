From: "Zhao Xiaoming" <xiaoming.nj@gmail.com>
Subject: Re: ZONE_NORMAL memory exhausted by 4000 TCP sockets
Date: Mon, 6 Nov 2006 18:21:43 +0800
Message-ID: <f55850a70611060221m77194aa6k4c14d8509809e491@mail.gmail.com>
References: <f55850a70611052207j384e1d3flaf40bb9dd74df7c5@mail.gmail.com>
	 <1162807984.3160.188.camel@laptopd505.fenrus.org>
	 <f55850a70611060221y25528116pa1b73aa89008f906@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752790AbWKFMLi@vger.kernel.org>
To: linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
In-Reply-To: <f55850a70611060221y25528116pa1b73aa89008f906@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

32 bit.  Of course 64 bit kernel can help me overcome the 900M
barrier. However, if I can't find the reason why so much memory
getting 'lost', it will be difficult to support more heavy loadded
concurrent TCP connections.

> 2006/11/6, Arjan van de Ven <arjan@infradead.org>:
> > On Mon, 2006-11-06 at 14:07 +0800, Zhao Xiaoming wrote:
> > > Dears,
> > >     I'm running a linux box with kernel version 2.6.16. The hardware
> > > has 2 Woodcrest Xeon CPUs (2 cores each) and 4G RAM. The NIC cards is
> > > Intel 82571 on PCI-e bus.
> >
> > are you using a 32 bit or a 64 bit OS?
> >
> >
> >
>

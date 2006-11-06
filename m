From: "Zhao Xiaoming" <xiaoming.nj@gmail.com>
Subject: Re: ZONE_NORMAL memory exhausted by 4000 TCP sockets
Date: Mon, 6 Nov 2006 18:21:12 +0800
Message-ID: <f55850a70611060221y25528116pa1b73aa89008f906@mail.gmail.com>
References: <f55850a70611052207j384e1d3flaf40bb9dd74df7c5@mail.gmail.com>
	 <1162807984.3160.188.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.192]:7310 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1423742AbWKFKVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 05:21:14 -0500
Received: by nz-out-0102.google.com with SMTP id z3so762061nzf
        for <netdev@vger.kernel.org>; Mon, 06 Nov 2006 02:21:12 -0800 (PST)
To: linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
In-Reply-To: <1162807984.3160.188.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2006/11/6, Arjan van de Ven <arjan@infradead.org>:
> On Mon, 2006-11-06 at 14:07 +0800, Zhao Xiaoming wrote:
> > Dears,
> >     I'm running a linux box with kernel version 2.6.16. The hardware
> > has 2 Woodcrest Xeon CPUs (2 cores each) and 4G RAM. The NIC cards is
> > Intel 82571 on PCI-e bus.
>
> are you using a 32 bit or a 64 bit OS?
>
>
>

From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [linux-next] sk->sk_dst_lock inconsistent lock state
Date: Mon, 16 Dec 2013 21:53:39 +0300
Message-ID: <20131216185339.GA2319@swordfish>
References: <20131216090412.GA2230@swordfish.minsk.epam.com>
 <1387201524.19078.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387201524.19078.227.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/16/13 05:45), Eric Dumazet wrote:
> On Mon, 2013-12-16 at 12:04 +0300, Sergey Senozhatsky wrote:
> > Hello,
> > 
> > 3.13.0-rc4-next-20131216
> 
> This is the third time we have this report.
>

sorry.
nice, thanks for the info.

	-ss

> http://patchwork.ozlabs.org/patch/301382/
> 
> Thanks
> 
> 

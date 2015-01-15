From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: [3.4] neigh_destroy() crashes on unplug netdev.
Date: Wed, 14 Jan 2015 23:03:19 -0800
Message-ID: <1421305399.11734.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <E694983F62A0954788A62E997021A9C31093E1@JPEX011.apo.epson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ueda Motoki <Ueda.Motoki@exc.epson.co.jp>,
	Otsu Takahiro <Otsu.Takahiro@exc.epson.co.jp>,
	Tomono Mitsunori <Tomono.Mitsunori@exc.epson.co.jp>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nakashima Akihiro <Nakashima.Akihiro@exc.epson.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E694983F62A0954788A62E997021A9C31093E1@JPEX011.apo.epson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-01-15 at 05:57 +0000, Nakashima Akihiro wrote:
> Dear David and networking developers:
> 
> I got kernel panic on 3.4.105 kernel.
> Please see a report below.

Please try a recent kernel.

We are not going to debug such an old one, given there are chances we
already fixed the problem ages ago.

Thanks

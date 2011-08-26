From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] p54spi: add "spi:" prefix for stlc45xx modalias
Date: Fri, 26 Aug 2011 16:51:29 +0200
Message-ID: <201108261651.29640.chunkeey@googlemail.com>
References: <1314340499.25655.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Axel Lin <axel.lin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314340499.25655.1.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, August 26, 2011 08:34:59 AM Axel Lin wrote:
> Since commit e0626e38 (spi: prefix modalias with "spi:"),
> the spi modalias is prefixed with "spi:".
> 
> This patch adds "spi:" prefix for modalias of stlc45xx.
> Also move it to be group with other modalias.
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>
> ---
sure, can't say no.
Acked-By: Christian Lamparter <chunkeey@googlemail.com>

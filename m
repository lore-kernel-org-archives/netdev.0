From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH] net/macb: GEM DMA configuration register update
Date: Fri, 23 Nov 2012 17:04:42 +0100
Message-ID: <CAGhQ9Vw=Yk7RAMVsBM71QWNjsD99PnrTgRs5+pK8V2e=HirQqg@mail.gmail.com>
References: <1353678541-26839-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353678541-26839-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 November 2012 14:49, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
> Add information to the DMA Configuration Register to
> maximize system performance:
> - rx/tx packet buffer full memory size
> - allow possibility to use INCR16 if supported
>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Acked-by: Joachim Eastwood <manabian@gmail.com

regards
Joachim Eastwood

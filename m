From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtl8xxxu: mark expected switch fall-throughs
Date: Wed, 11 Oct 2017 03:20:37 -0700
Message-ID: <1507717237.3552.48.camel@perches.com>
References: <20171010193027.GA23108@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@infradead.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Jes Sorensen <Jes.Sorensen@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010193027.GA23108@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-10 at 14:30 -0500, Gustavo A. R. Silva wrote:
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.

perhaps use Arnaldo's idea:

https://lkml.org/lkml/2017/2/9/845
https://lkml.org/lkml/2017/2/10/485

From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: wireless: mark expected switch fall-throughs
Date: Mon, 23 Oct 2017 08:48:18 +0200
Message-ID: <1508741298.2639.7.camel@sipsolutions.net>
References: <20171020172145.GA5366@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020172145.GA5366@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-10-20 at 12:21 -0500, Gustavo A. R. Silva wrote:
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
> This code was tested by compilation only (GCC 7.2.0 was used).
> Please, verify if the actual intention of the code is to fall through.

Please, if you're proposing patches, do that yourself.

johannes

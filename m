From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH] brcmsmac: Use current logging styles
Date: Mon, 14 Nov 2011 11:13:43 +0100
Message-ID: <4EC0E9D7.7080304@broadcom.com>
References: <1321213264.15834.4.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321213264.15834.4.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2011 08:41 PM, Joe Perches wrote:
> Add and use pr_fmt and pr_<level>
> Remove useless double parentheses from macros.
> Remove function names from format strings, add to pr_debug use.
> Coalesce formats.
> Remove uncompileable undeclared variable in a DMA_NONE use.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/brcm80211/brcmsmac/aiutils.c |   14 +-
>  drivers/net/wireless/brcm80211/brcmsmac/dma.c     |  145 ++++++++++-----------
>  2 files changed, 80 insertions(+), 79 deletions(-)

Thanks for the service.

Acked-by: Arend van Spriel <arend@broadcom.com>

Gr. AvS

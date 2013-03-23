From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH] brcmsmac: Remove unused macro SI_MSG
Date: Sat, 23 Mar 2013 13:14:05 +0100
Message-ID: <514D9C8D.20302@broadcom.com>
References: <25a69b0ba20a54e5c1c0165e68a1ef2c69c84255.1363982285.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Brett Rudley" <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"Hante Meuleman" <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <25a69b0ba20a54e5c1c0165e68a1ef2c69c84255.1363982285.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2013 09:00 PM, Joe Perches wrote:
> commit 6236dc2e2 ("brcmsmac: remove some redundant chip common workarounds")
> removed the last uses.

Good riddance.

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/brcm80211/brcmsmac/aiutils.c | 6 ------
>  1 file changed, 6 deletions(-)

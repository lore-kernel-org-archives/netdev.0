From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH v7 27/33] net: tile - set name assign type
Date: Wed, 16 Jul 2014 13:49:49 -0400
Message-ID: <53C6BB3D.5010605@tilera.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no> <1404980258-30853-28-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>
To: Tom Gundersen <teg@jklm.no>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-28-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/10/2014 4:23 AM, Tom Gundersen wrote:
> The name is obtained from the 'hardware', so consider it predictable.
>
> Signed-off-by: Tom Gundersen<teg@jklm.no>
> Cc: Chris Metcalf<cmetcalf@tilera.com>
> ---
>   drivers/net/ethernet/tile/tilegx.c  |  7 ++++---
>   drivers/net/ethernet/tile/tilepro.c | 13 +++++++------
>   2 files changed, 11 insertions(+), 9 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

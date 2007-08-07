From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 68] drivers/net/s2io.c: kmalloc + memset conversion to
 k[cz]alloc
Date: Tue, 07 Aug 2007 17:57:36 -0400
Message-ID: <46B8EAD0.2040303@pobox.com>
References: <200707311845.48807.m.kozlowski@tuxland.pl> <200707312356.58934.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <200707312356.58934.m.kozlowski@tuxland.pl>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mariusz Kozlowski wrote:
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/s2io.c | 235587 -> 235340 (-247 bytes)
>  drivers/net/s2io.o | 460768 -> 460120 (-648 bytes)
> 
>  drivers/net/s2io.c |   14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)

ACK but didn't apply, please wait 24-48 hours (so that s2io fixes go 
upstream), then rediff and resend



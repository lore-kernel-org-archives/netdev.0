From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 69] drivers/net/sb1250-mac.c: kmalloc + memset conversion
 to kcalloc
Date: Tue, 07 Aug 2007 17:57:43 -0400
Message-ID: <46B8EAD7.2040105@pobox.com>
References: <200707311845.48807.m.kozlowski@tuxland.pl> <200707312358.36567.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50626 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936784AbXHGV5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 17:57:45 -0400
In-Reply-To: <200707312358.36567.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mariusz Kozlowski wrote:
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/sb1250-mac.c | 76286 -> 76199 (-87 bytes)
> 
>  drivers/net/sb1250-mac.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)

applied



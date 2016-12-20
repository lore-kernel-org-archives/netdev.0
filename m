From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH] ethernet: sfc: Add Kconfig entry for vendor Solarflare
Date: Tue, 20 Dec 2016 17:29:08 +0000
Message-ID: <5715cd11-87f9-793f-212e-995d05258b40@solarflare.com>
References: <20161220133826.1478-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <bkenward@solarflare.com>
To: Tobias Klauser <tklauser@distanz.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:60235 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933809AbcLTR3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 12:29:21 -0500
In-Reply-To: <20161220133826.1478-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/12/16 13:38, Tobias Klauser wrote:
> Since commit
>
>   5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")
>
> there are two drivers for Solarflare devices, but both still show up
> directly beneath "Ethernet driver support" in the Kconfig. Follow the
> pattern of other vendors and group them beneath an own vendor Kconfig
> entry for Solarflare.
>
> Cc: Edward Cree <ecree@solarflare.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Acked-by: Edward Cree <ecree@solarflare.com>

From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] doc: Update VRF documentation metric
Date: Wed, 18 Oct 2017 08:25:54 -0600
Message-ID: <c8b254bb-ee60-64e2-bab6-e6d0c894c06f@cumulusnetworks.com>
References: <20171018142428.26398-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Donald Sharp <sharpd@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:46038 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750935AbdJROZw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:25:52 -0400
Received: by mail-pg0-f66.google.com with SMTP id b192so4411742pga.2
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:25:52 -0700 (PDT)
In-Reply-To: <20171018142428.26398-1-sharpd@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/17 8:24 AM, Donald Sharp wrote:
> Two things:
> 
> 1) Update examples to show usage of metric
> 2) Discuss reasoning for using such a high metric.
> 
> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
> ---
>  Documentation/networking/vrf.txt | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 

For net-next.

Acked-by: David Ahern <dsa@cumulusnetworks.com>

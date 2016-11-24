From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [patch net-next] sfc: remove unneeded variable
Date: Thu, 24 Nov 2016 12:03:56 +0000
Message-ID: <7620ba33-2595-5315-821e-1cfc59a727ce@solarflare.com>
References: <20161124111651.GJ17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:52777 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S938647AbcKXMEK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 07:04:10 -0500
In-Reply-To: <20161124111651.GJ17225@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/11/16 11:16, Dan Carpenter wrote:
> We don't use ->heap_buf after commit 46d1efd852cc ("sfc: remove Software
> TSO") so let's remove the last traces.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Bert Kenward <bkenward@solarflare.com>

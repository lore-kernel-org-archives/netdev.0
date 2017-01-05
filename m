From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4] net: ethernet: faraday: To support device tree usage.
Date: Thu, 05 Jan 2017 22:55:10 +0100
Message-ID: <2495085.ah3UxQXxeO@wuerfel>
References: <20170105102345.GA25774@app09>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, andrew@lunn.ch,
        linux-kernel@vger.kernel.org, jiri@resnulli.us,
        jonas.jensen@gmail.com, davem@davemloft.net
To: Greentime Hu <green.hu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:50659 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933035AbdAEVzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 16:55:35 -0500
In-Reply-To: <20170105102345.GA25774@app09>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, January 5, 2017 6:23:53 PM CET Greentime Hu wrote:
> Signed-off-by: Greentime Hu <green.hu@gmail.com>
> ---
> Changes in v4:
>   - Use the same binding document to describe the same faraday ethernet controller and add faraday to vendor-prefixes.txt.
> Changes in v3:
>   - Nothing changed in this patch but I have committed andestech to vendor-prefixes.txt.
> Changes in v2:
>   - Change atmac100_of_ids to ftmac100_of_ids
> 

The patch looks good to me now, but please add a proper commit log
before your Signed-off-by tag.

	Arnd

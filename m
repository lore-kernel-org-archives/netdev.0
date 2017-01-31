From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 3/3] net: bgmac: use PHY subsystem for initializing PHY
Date: Tue, 31 Jan 2017 10:07:34 -0800
Message-ID: <87d6def2-cf61-605d-b6e9-7eb8f4241938@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
 <20170128210832.26174-4-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33846 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751849AbdAaSHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:07:42 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so29050844pfb.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:07:41 -0800 (PST)
In-Reply-To: <20170128210832.26174-4-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2017 01:08 PM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> This adds support for using bgmac with PHYs supported by standalone PHY
> drivers. Having any PHY initialization in bgmac is hacky and shouldn't
> be extended but rather removed if anyone has hardware to test it.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian

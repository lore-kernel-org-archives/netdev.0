From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] net: dsa: b53/bcm_sf2 cleanups
Date: Mon, 18 Sep 2017 16:24:21 -0700 (PDT)
Message-ID: <20170918.162421.393653763418019686.davem@davemloft.net>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
        <24876029-5ebb-075e-3f02-50cf0856474f@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750982AbdIRXYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:24:25 -0400
In-Reply-To: <24876029-5ebb-075e-3f02-50cf0856474f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 18 Sep 2017 14:46:48 -0700

> On 09/18/2017 02:41 PM, Florian Fainelli wrote:
>> Hi all,
>> 
>> This patch series is a first pass set of clean-ups to reduce the number of LOCs
>> between b53 and bcm_sf2 and sharing as many functions as possible.
>> 
>> There is a number of additional cleanups queued up locally that require more
>> thorough testing.
> 
> David, I just spotted a missing EXPORT_SYMBOL() in patch 8 that was not
> flagged since I had temporarily disabled modular build, I will resubmit
> this shortly after checking the other patches too. Thanks!

Ok.

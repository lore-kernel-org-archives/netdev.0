From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 7/7] net: korina: bump version
Date: Sun, 17 Sep 2017 13:01:56 -0700
Message-ID: <5eb304a1-8567-f898-5f45-85d55e807231@gmail.com>
References: <20170917172521.32639-1-roman@advem.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Roman Yeryomin <leroi.lists@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33961 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750850AbdIQUB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 16:01:59 -0400
Received: by mail-io0-f196.google.com with SMTP id g32so7212966ioj.1
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 13:01:59 -0700 (PDT)
In-Reply-To: <20170917172521.32639-1-roman@advem.lv>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/17/2017 10:25 AM, Roman Yeryomin wrote:
> Signed-off-by: Roman Yeryomin <roman@advem.lv>

You can probably drop the version because it does not really make much
sense for an in-kernel driver anyway.
-- 
Florian

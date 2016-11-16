From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 0/3] net: ethernet: Allow Marvell & Freescale
 to COMPILE_TEST
Date: Wed, 16 Nov 2016 11:07:20 -0800
Message-ID: <730026e4-9dd7-df74-ca67-8c3dc01dbf1f@gmail.com>
References: <20161116004037.20941-1-f.fainelli@gmail.com>
 <20161116.140258.1654275132379916645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36783 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbcKPTHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 14:07:23 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so15383931pgx.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 11:07:22 -0800 (PST)
In-Reply-To: <20161116.140258.1654275132379916645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2016 11:02 AM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 15 Nov 2016 16:40:32 -0800
> 
>> This patch series allows most of the Freescale Ethernet drivers to
>> be built with COMPILE_TEST and all Marvell drivers to build with
>> COMPILE_TEST.
> 
> Looks like the kbuild robot found some problems with this.
> 

Indeed, let me try to address these and then resubmit. Thanks!
-- 
Florian

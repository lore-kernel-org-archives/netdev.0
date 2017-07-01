From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2017-07-01
Date: Sat, 01 Jul 2017 15:58:18 -0700 (PDT)
Message-ID: <20170701.155818.1192612802590994151.davem@davemloft.net>
References: <20170701181950.GA27217@x1c.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdGAW7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 18:59:07 -0400
In-Reply-To: <20170701181950.GA27217@x1c.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Sat, 1 Jul 2017 21:19:50 +0300

> Here are some more Bluetooth patches for the 4.13 kernel:
> 
>  - Added support for Broadcom BCM43430 controllers
>  - Added sockaddr length checks before accessing sa_family
>  - Fixed possible "might sleep" errors in bnep, cmtp and hidp modules
>  - A few other minor fixes
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.

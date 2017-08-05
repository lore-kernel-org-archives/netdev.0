From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] aquantia: Switch to use napi_gro_receive
Date: Fri, 04 Aug 2017 20:57:28 -0700 (PDT)
Message-ID: <20170804.205728.1181515274061477227.davem@davemloft.net>
References: <5ba75da7aa9caa1feb85e65edd47965fe0226ab6.1501771297.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com,
        Igor.Russkikh@aquantia.com, simon.edelhaus@aquantia.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdHED5d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 23:57:33 -0400
In-Reply-To: <5ba75da7aa9caa1feb85e65edd47965fe0226ab6.1501771297.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Thu,  3 Aug 2017 18:15:32 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> Add support for GRO (generic receive offload) for aQuantia Atlantic driver.
> This results in a perfomance improvement when GRO is enabled.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

Applied, thank you.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: unexport dsa_is_port_initialized
Date: Wed, 19 Jul 2017 16:28:36 -0700 (PDT)
Message-ID: <20170719.162836.944359459689323354.davem@davemloft.net>
References: <20170718202356.7178-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932529AbdGSX2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 19:28:37 -0400
In-Reply-To: <20170718202356.7178-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 18 Jul 2017 16:23:56 -0400

> The dsa_is_port_initialized helper is only used by dsa_switch_resume and
> dsa_switch_suspend, if CONFIG_PM_SLEEP is enabled. Make it static to
> dsa.c.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.

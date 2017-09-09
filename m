From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 3/3] net: phy: sfp: rename dt properties to
 match the binding
Date: Fri, 08 Sep 2017 20:51:48 -0700 (PDT)
Message-ID: <20170908.205148.1209592721612033847.davem@davemloft.net>
References: <b98ac3e8cde5c99489e8dcee9a1d5b8a19face8d.1504776350.git.baruch@tkos.co.il>
        <720bdc3383214231cd6e25d2e1980262c68863ac.1504776350.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, andrew@lunn.ch,
        f.fainelli@gmail.com, rmk+kernel@arm.linux.org.uk,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        sergei.shtylyov@cogentembedded.com,
        antoine.tenart@free-electrons.com
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42924 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757279AbdIIDvt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 23:51:49 -0400
In-Reply-To: <720bdc3383214231cd6e25d2e1980262c68863ac.1504776350.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Thu,  7 Sep 2017 12:25:50 +0300

> Make the Rx rate select control gpio property name match the documented
> binding. This would make the addition of 'rate-select1-gpios' for SFP+
> support more natural.
> 
> Also, make the MOD-DEF0 gpio property name match the documentation.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied.

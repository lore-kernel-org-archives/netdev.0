From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 6/7 v3] au1000-eth: remove volatiles, switch to I/O accessors
Date: Wed, 8 Sep 2010 23:14:02 +0200
Message-ID: <201009082314.03167.florian@openwrt.org>
References: <201009082311.53406.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59879 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab0IHVMw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:12:52 -0400
Received: by wyf22 with SMTP id 22so490306wyf.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 14:12:51 -0700 (PDT)
In-Reply-To: <201009082311.53406.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 8 September 2010 23:11:52, Florian Fainelli a =C3=A9crit :
> Remove all the volatile keywords where they were used, switch to usin=
g the
> proper readl/writel accessors.

Sorry for the double attachment. Proper patch in reply of this one.

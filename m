From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] aquantia: Fix driver name reported by ethtool
Date: Thu, 04 May 2017 11:07:59 -0400 (EDT)
Message-ID: <20170504.110759.1866646536158042525.davem@davemloft.net>
References: <2082aed4d8196250542cf9a73f3d9a49eb96af21.1493835234.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55692 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754264AbdEDPIA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:08:00 -0400
In-Reply-To: <2082aed4d8196250542cf9a73f3d9a49eb96af21.1493835234.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Wed,  3 May 2017 21:17:44 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> V2: using "aquantia" subsystem tag.
> 
> The command "ethtool -i ethX" should display driver name (driver: atlantic)
> instead vendor name (driver: aquantia).
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/{mii,smsc}: Make mii_ethtool_get_link_ksettings
 and smc_netdev_get_ecmd return void
Date: Mon, 05 Jun 2017 11:01:45 -0400 (EDT)
Message-ID: <20170605.110145.2053472151656679350.davem@davemloft.net>
References: <20170604172200.4177-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, pcnet32@frontier.com,
        hsweeten@visionengravers.com, jeffrey.t.kirsher@intel.com,
        cooldavid@cooldavid.org, mcuos.com@gmail.com, nic_swsd@realtek.com,
        ralf@linux-mips.org, romieu@fr.zoreil.com, nico@fluxnic.net,
        oneukum@suse.com, tremyfr@gmail.com, paul.gortmaker@windriver.com,
        jarod@redhat.com, green.hu@gmail.com, f.fainelli@gmail.com,
        edumazet@google.com, shchers@gmail.com, stephen.boyd@linaro.org,
        fgao@48lvckh6395k16k5.yundunddos.com, tklauser@distanz.ch,
        jay.vosburgh@canonical.com, robert.jarzmik@free.fr,
        jeremy.linton@arm.com, rmk+kernel@armlinux.org.uk,
        stephen@networkplumber.org, arnd@arndb.de, gerg@linux-m68k.org,
        allan@asix.com.tw, chris.roth@usask.ca, hayeswang@realtek.com,
        mario_limonciello@dell.com, netdev@vger.kernel.org,
        linux-parisc@
To: yuval.shaia@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdFEPBw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 11:01:52 -0400
In-Reply-To: <20170604172200.4177-1-yuval.shaia@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Shaia <yuval.shaia@oracle.com>
Date: Sun,  4 Jun 2017 20:22:00 +0300

> Make return value void since functions never returns meaningfull value.
> 
> Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>

Applied to net-next.

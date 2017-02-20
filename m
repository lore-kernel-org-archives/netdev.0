From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] nfp: expose more firmware and hw debug
 info
Date: Mon, 20 Feb 2017 11:19:06 -0500 (EST)
Message-ID: <20170220.111906.1245560346456339472.davem@davemloft.net>
References: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        dinan.gunawardena@netronome.com, kubakici@wp.pl
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754091AbdBTQTI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:19:08 -0500
In-Reply-To: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sun, 19 Feb 2017 11:58:07 -0800

> This series is mostly a result of flash firmware team requesting 
> access to some of the information and data necessary for debugging 
> firmware problems.  Patch 1 adds a missing error message.  Patch 2 
> prints manufacturing info to logs in case PCI VPD capability is 
> not programmed correctly.  Patches 3 and 4 allow reporting NSP ABI
> version in ethtool -i.  Patch 5 allows dumping flash application 
> logs.  
> 
> Patches 6 and 7 provides a way of application firmwares to declare 
> limited SR-IOV support.
> 
> v2: put some of the code in patch 7 in #ifdef CONFIG_PCI_SRIOV (Yuval).

Series applied, thanks.

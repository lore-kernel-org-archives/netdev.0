From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] net: mvneta: implement .set_wol and .get_wol
Date: Sun, 22 Jan 2017 23:27:52 -0500 (EST)
Message-ID: <20170122.232752.1219062119314154291.davem@davemloft.net>
References: <1485139447-11067-1-git-send-email-houjingj@marvell.com>
        <201701231207.slqpC1Wl%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: houjingj@marvell.com, kbuild-all@01.org, jszhang@marvell.com,
        thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org
To: lkp@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43962 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbdAWE1y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:27:54 -0500
In-Reply-To: <201701231207.slqpC1Wl%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The same build error exists in all submissions of your patch.

At this point you must absolutely reproduce this build failure
yourself, and stop submitting this patch until you can test that the
build failure is fixed.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] selftest/net/Makefile: Specify output with
 $(OUTPUT)
Date: Sat, 17 Jun 2017 22:48:22 -0400 (EDT)
Message-ID: <20170617.224822.999999703835025104.davem@davemloft.net>
References: <20170618005604.17639-1-sj38.park@gmail.com>
        <20170618005604.17639-4-sj38.park@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shuah@kernel.org, bamvor.zhangjian@linaro.org, shorne@gmail.com,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: sj38.park@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751923AbdFRCxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 22:53:00 -0400
In-Reply-To: <20170618005604.17639-4-sj38.park@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: SeongJae Park <sj38.park@gmail.com>
Date: Sun, 18 Jun 2017 09:56:04 +0900

> After commit a8ba798bc8ec ("selftests: enable O and KBUILD_OUTPUT"),
> net selftest build fails because it points output file without $(OUTPUT)
> yet.  This commit fixes the error.
> 
> Signed-off-by: SeongJae Park <sj38.park@gmail.com>
> Fixes: a8ba798bc8ec ("selftests: enable O and KBUILD_OUTPUT")

Acked-by: David S. Miller <davem@davemloft.net>

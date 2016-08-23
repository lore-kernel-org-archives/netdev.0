From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Fix address macros
Date: Mon, 22 Aug 2016 22:41:43 -0700 (PDT)
Message-ID: <20160822.224143.1425957059878556742.davem@davemloft.net>
References: <1471925990-30782-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48393 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755029AbcHWFly (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 01:41:54 -0400
In-Reply-To: <1471925990-30782-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 23 Aug 2016 07:19:50 +0300

> Last FW submission reverted various macros into an older form,
> where they generate compilation warnings on some architectures.
> 
> Bring back the newer macros instead.
> 
> Fixes: 05fafbfb3d77 ("qed: utilize FW 8.10.10.0")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib: test_rhashtable: Fix KASAN warning
Date: Tue, 25 Jul 2017 12:36:07 -0700 (PDT)
Message-ID: <20170725.123607.1589301148475463278.davem@davemloft.net>
References: <20170725113621.1425-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751927AbdGYTgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 15:36:08 -0400
In-Reply-To: <20170725113621.1425-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Tue, 25 Jul 2017 13:36:21 +0200

> I forgot one spot when introducing struct test_obj_val.
> 
> Fixes: e859afe1ee0c5 ("lib: test_rhashtable: fix for large entry counts")
> Reported by: kernel test robot <fengguang.wu@intel.com>
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Please don't put empty lines in the middle of a set of tags like that.
I fixed it up this time :)

Applied, thanks.

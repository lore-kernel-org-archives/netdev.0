From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next][V3] bpf: test_maps: fix typos, "conenct" and
 "listeen"
Date: Wed, 30 Aug 2017 15:32:59 -0700 (PDT)
Message-ID: <20170830.153259.1704807278686660573.davem@davemloft.net>
References: <20170830171525.5688-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, shuah@kernel.org,
        netdev@vger.kernel.org, linux-kselftest@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751664AbdH3WdA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:33:00 -0400
In-Reply-To: <20170830171525.5688-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Wed, 30 Aug 2017 18:15:25 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to typos in printf error messages:
> "conenct" -> "connect"
> "listeen" -> "listen"
> 
> thanks to Daniel Borkmann for spotting one of these mistakes
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.

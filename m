From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] selftests: bpf: add check for ip XDP
 redirect
Date: Fri, 11 Aug 2017 14:57:44 -0700 (PDT)
Message-ID: <20170811.145744.1492565969678067555.davem@davemloft.net>
References: <1502459199-6442-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753809AbdHKV5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:57:45 -0400
In-Reply-To: <1502459199-6442-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Fri, 11 Aug 2017 06:46:39 -0700

> Kernel test robot reports error when running test_xdp_redirect.sh.
> Check if ip tool supports xdpgeneric, if not, skip the test.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thank you.

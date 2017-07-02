From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix to bpf_setsockops
Date: Sun, 02 Jul 2017 15:17:20 -0700 (PDT)
Message-ID: <20170702.151720.1824583871623683342.davem@davemloft.net>
References: <20170702161428.3133994-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751894AbdGBWR3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2017 18:17:29 -0400
In-Reply-To: <20170702161428.3133994-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Sun, 2 Jul 2017 09:14:28 -0700

> Fixed build error due to misplaced "#ifdef CONFIG_INET" (moved 1
> statement up).
> 
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Applied, thank you.

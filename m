From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Fix inaccurate helper function description
Date: Sun, 30 Apr 2017 22:25:32 -0400 (EDT)
Message-ID: <20170430.222532.1945595185772507111.davem@davemloft.net>
References: <1493250083-1954-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mic@digikod.net, fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642297AbdEACZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:25:35 -0400
In-Reply-To: <1493250083-1954-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Wed, 26 Apr 2017 16:41:23 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> The description inside uapi/linux/bpf.h about bpf_get_socket_uid
> helper function is no longer valid. It returns overflowuid rather
> than 0 when failed.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Applied.

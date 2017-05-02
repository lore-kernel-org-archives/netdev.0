From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, samples: fix build warning in
 cookie_uid_helper_example
Date: Mon, 01 May 2017 21:30:07 -0400 (EDT)
Message-ID: <20170501.213007.1110696276930355124.davem@davemloft.net>
References: <43325f50d66abec6b35439422b6c9b0211bd30e9.1493678555.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdEBBaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 21:30:12 -0400
In-Reply-To: <43325f50d66abec6b35439422b6c9b0211bd30e9.1493678555.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue,  2 May 2017 00:47:09 +0200

> Fix the following warnings triggered by 51570a5ab2b7 ("A Sample of
> using socket cookie and uid for traffic monitoring"):
 ...
> Fixes: 51570a5ab2b7 ("A Sample of using socket cookie and uid for traffic monitoring")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.

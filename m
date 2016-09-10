From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: hold the transport before using it in sctp_hash_cmp
Date: Sat, 10 Sep 2016 23:08:08 +0800
Message-ID: <CADvbK_eYwasmVANJUXdaeHuHWS+Y3kNYmFPy-gU3F8Dh0O4h4A@mail.gmail.com>
References: <f71c2e03ae6e9b956f41c73fff5a282c86d79daf.1473328144.git.lucien.xin@gmail.com>
 <20160909.191746.1850636311022712919.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vladislav Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:34389 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754091AbcIJPOU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 11:14:20 -0400
In-Reply-To: <20160909.191746.1850636311022712919.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Please add more detail to the commit message and add a proper
> "Fixes: " tag right before your signoff.
OK, will repost v2

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: account all retransmit failures
Date: Fri, 12 Jul 2013 11:55:54 -0700
Message-ID: <1373655354.10804.38.camel@edumazet-glaptop>
References: <1373653984-30249-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:49223 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965176Ab3GLSz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 14:55:56 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so8793563pdj.8
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 11:55:55 -0700 (PDT)
In-Reply-To: <1373653984-30249-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-12 at 11:33 -0700, Yuchung Cheng wrote:
> Change snmp RETRANSFAILS stat to include timeout retransmit failures
> in addition to other loss recoveries.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>

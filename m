From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net-next] secure_seq: fix sparse errors
Date: Thu, 12 Jan 2017 12:42:42 +0100
Message-ID: <CAHmME9qxDZtimi6kb1OvuqOK9khDx5Qxqg4aAZpO9d=uKS5Ang@mail.gmail.com>
References: <1484187037.15816.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:34300 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751095AbdALLnb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 06:43:31 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id a913b3ad
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 11:32:46 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 9facaa11 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 11:32:45 +0000 (UTC)
Received: by mail-oi0-f52.google.com with SMTP id w204so19703531oiw.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 03:42:43 -0800 (PST)
In-Reply-To: <1484187037.15816.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice catch, thanks.

Reviewed-by: Jason A. Donenfeld <Jason@zx2c4.com>

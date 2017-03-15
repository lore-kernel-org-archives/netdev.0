From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 09:27:46 -0700
Message-ID: <1489595266.28631.153.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170314151143.16231-1-edumazet@google.com>
         <60f6dc92-511d-b7be-64d2-2532e112d845@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36692 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752736AbdCOQ1t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 12:27:49 -0400
Received: by mail-pf0-f178.google.com with SMTP id o126so11082500pfb.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 09:27:48 -0700 (PDT)
In-Reply-To: <60f6dc92-511d-b7be-64d2-2532e112d845@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-15 at 17:36 +0200, Tariq Toukan wrote:

> 
> Hi Eric,
> 
> Thanks for your patch.
> 
> I will do the XDP tests and complete the review, by tomorrow.
> 

Thanks a lot Tariq !

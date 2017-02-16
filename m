From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Thu, 16 Feb 2017 07:30:28 -0800
Message-ID: <1487259028.1311.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9bFC1nVC1Sp3WiAf_OkO_6O9XYqJGRn21yg32NYey6Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33841 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932172AbdBPPa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:30:29 -0500
Received: by mail-pf0-f193.google.com with SMTP id o64so1862417pfb.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:30:29 -0800 (PST)
In-Reply-To: <CALzJLG9bFC1nVC1Sp3WiAf_OkO_6O9XYqJGRn21yg32NYey6Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-16 at 14:38 +0200, Saeed Mahameed wrote:

> Acked-by: Saeed Mahameed <saeedm@mellanox.com>

Thanks for reviewing this Saeed !

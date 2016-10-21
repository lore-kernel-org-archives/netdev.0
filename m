From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] ipv6: do not increment mac header when it's unset
Date: Fri, 21 Oct 2016 18:27:45 +0900
Message-ID: <CAHmME9q5yDae6qXecKK-Cdw-91geRnvzYocg=ypFucH+9LVt_g@mail.gmail.com>
References: <20161021083954.20941-1-Jason@zx2c4.com> <20161021090042.26039-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Pipacs <pageexec@gmail.com>,
        Emese Revfy <re.emese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40869 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933076AbcJUJ1u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 05:27:50 -0400
In-Reply-To: <20161021090042.26039-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry. Jetlagged. Resubmitting without the cruft.

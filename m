From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Implement rfc7559 ipv6 router solicitation backoff
Date: Sun, 25 Sep 2016 01:01:57 +0900
Message-ID: <CAHo-Oozocj2rzY8hTTr1f3roMy9iz50j6X=dBG5qmz4B_LFAFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NetDev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:35253 "EHLO
        mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754578AbcIXQB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 12:01:59 -0400
Received: by mail-yw0-f169.google.com with SMTP id u82so133239730ywc.2
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 09:01:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


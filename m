From: Erik Kline <ek@google.com>
Subject: Re: [PATCH] ipv6 addrconf: implement RFC7559 router solicitation backoff
Date: Thu, 29 Sep 2016 18:56:45 +0900
Message-ID: <CAAedzxo0=BsOV6SF9a+9DuiQ7AtQnWx-JyxJaPXmU_HHzee5Hw@mail.gmail.com>
References: <1475045878-30455-1-git-send-email-zenczykowski@gmail.com>
 <1475048569.3276913.739336609.4398C277@webmail.messagingengine.com> <CANP3RGe4jMRhepM5v2Dg4Kq3Rxj=tA7WJEMcD_83DLYcEgujMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38088 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbcI2J5I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 05:57:08 -0400
Received: by mail-wm0-f50.google.com with SMTP id w72so15983559wmf.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 02:57:07 -0700 (PDT)
In-Reply-To: <CANP3RGe4jMRhepM5v2Dg4Kq3Rxj=tA7WJEMcD_83DLYcEgujMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passes my local unittest for this behaviour.

Acked-by: Erik Kline <ek@google.com>

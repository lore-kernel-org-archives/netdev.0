From: Roman Savchenko <gmstima@gmail.com>
Subject: AF_PACKET can't be received on local machine
Date: Thu, 8 Sep 2016 11:50:16 +0300
Message-ID: <CAGpdKUKwheqFRxFxy32ukzupwZyOHY4i5oZ++xSoATfF=o23Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:35679 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932881AbcIHIuS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 04:50:18 -0400
Received: by mail-ua0-f172.google.com with SMTP id 95so10445927uaz.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 01:50:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

I created UDP packet with AF_PACKET and SOCK_RAW. It was successfully
received on another physical machine, but I have problem to receive it
localy. I searched a bit and found that other people have such problem
too:

stackoverflow.com/questions/12103541/cant-send-raw-packets-to-local-mac-with-pf-packet
http://stackoverflow.com/questions/33484762/packet-sockets-not-receiving-data-for-custom-protocol-id
http://stackoverflow.com/questions/23288188/cannot-receive-raw-ethernet-frame-packets-i-just-sent

So my question is it allowed? How can it be done?

Many thanks,
R. Savchenko.

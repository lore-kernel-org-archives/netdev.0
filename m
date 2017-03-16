From: Maxim Uvarov <muvarov@gmail.com>
Subject: port mirror on dsa switches?
Date: Thu, 16 Mar 2017 13:32:01 +0300
Message-ID: <CAJGZr0JzRZHTkdKCqFrwAG5fj-j3Ez2DYVOygiE9oQ3BTHZ4FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:34685 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbdCPKcD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:32:03 -0400
Received: by mail-ua0-f182.google.com with SMTP id f54so23478817uaa.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 03:32:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Some dsa switches can support port mirror in hardware. Does somebody
have any idea how to
work with it from linux side in generic way?

That might be part of 'struct dsa_switch_ops', but it's not clear
which user space app should control that.
The same question about QoS set up on dsa switch ports.

-- 
Best regards,
Maxim Uvarov

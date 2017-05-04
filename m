From: Oleg <lego12239@yandex.ru>
Subject: struct ip vs struct iphdr
Date: Thu, 4 May 2017 19:42:19 +0300
Message-ID: <20170504164219.GA25287@legohost>
Reply-To: Oleg <lego12239@yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward6h.cmail.yandex.net ([87.250.230.217]:46831 "EHLO
        forward6h.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752384AbdEDQtH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:49:07 -0400
Received: from smtp3h.mail.yandex.net (smtp3h.mail.yandex.net [84.201.186.20])
        by forward6h.cmail.yandex.net (Yandex) with ESMTP id 7B2B421A31
        for <netdev@vger.kernel.org>; Thu,  4 May 2017 19:41:30 +0300 (MSK)
Received: from smtp3h.mail.yandex.net (localhost.localdomain [127.0.0.1])
        by smtp3h.mail.yandex.net (Yandex) with ESMTP id 4DF1A440DCD
        for <netdev@vger.kernel.org>; Thu,  4 May 2017 19:41:29 +0300 (MSK)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hi, all.

It seems struct ip and struct iphdr are similar: struct ip, despite of
it name, doesn't contain anything but ip header.

So, my noob question, what is the difference between them?

Thanks.

-- 
Олег Неманов (Oleg Nemanov)

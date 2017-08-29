From: Ravish Kumar <ravishk2004@gmail.com>
Subject: Hooking on L4 Level with process information
Date: Tue, 29 Aug 2017 07:34:51 +0530
Message-ID: <CAEDnJmJZ1-4DFtjmzDO1US2HCuHYDkcsa+tk8mN3CZ6vcDLbVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34659 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbdH2CEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 22:04:53 -0400
Received: by mail-vk0-f52.google.com with SMTP id s199so6122882vke.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 19:04:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I want to hook tcp/udp packets on L4 Layer and based on process
information , content want to deny or allow packets.

Netfilter provides pre/post Routing hooks but not sure that will be
right place so thought of asking whether my approach is right.
Also how i can get process information whether this packet is send by
this process.

Thoughts /source code reference would be appreciated.

Regards,
Ravish

From: Ran Shalit <ranshalit@gmail.com>
Subject: Q: How to disable vlan strip in Intel igb driver ?
Date: Sun, 1 May 2016 16:13:09 +0300
Message-ID: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37254 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbcEANNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 09:13:10 -0400
Received: by mail-ig0-f178.google.com with SMTP id s8so55439333ign.0
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 06:13:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,


I am using intel igb driver in Linux.

The driver strip the packet from vlan inofmation. But we need this
information in the packet.

We tried to change build flag, or see if there is any feature with
ethtool that can disable this feature, but nothing helps.


Is there any way to achive this ?

Regards,

Ran

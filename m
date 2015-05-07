From: sainath grandhi <saiallforums@gmail.com>
Subject: packet tracing
Date: Wed, 6 May 2015 23:16:32 -0700
Message-ID: <CABqzqi5f7JMY7MLXxeUn1_vdO9j0uL3-_eZ8fdp349rX1Kz7cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:35204 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbEGGQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 02:16:33 -0400
Received: by qgej70 with SMTP id j70so16250157qge.2
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 23:16:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
    Is there any debug message framework in place for tracking a
network packet as it passes through different kernel stack layers
(layer 3, layer 2, bridge devices, drivers etc)?

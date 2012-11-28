From: Javier Domingo <javierdo1@gmail.com>
Subject: Specific question about packet dropping
Date: Wed, 28 Nov 2012 11:40:32 +0100
Message-ID: <CALZVapnQrH9YvCOh8OnGFs1V28nPfX4p=GK=M0VnqHjZCU8=1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:58162 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072Ab2K1Kkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 05:40:53 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so9986617vcm.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 02:40:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Where are packets dropped?

I reading code I think just found:
- In the NIC
- In the netif_receive_skb

Is there any other place I can have missed?

Javier Domingo

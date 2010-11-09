From: Kevin Wilson <wkevils@gmail.com>
Subject: alloc_netdev_mq() and multiqueues
Date: Tue, 9 Nov 2010 20:33:53 +0200
Message-ID: <AANLkTi=8PrpAB+ARt-H3niNjnmQgHF1Ass345e95_pdq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47363 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab0KISdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 13:33:54 -0500
Received: by fxm16 with SMTP id 16so5203467fxm.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 10:33:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I have a short question about multiqueues  and I will appreciate if
somebody can answer shortly in 2-3 sentences.
When talking about multiqueues  I refer for example, to
http://nfws.edenwall.com/nfws_userday/David-Miller_Linux-Multiqueue-Networking.pdf,
alloc_netdev_mq() and friends.

1) Does an ordinary network driver code can be adjusted to use
multiqueues ? or do we need some
special hardware feature ?
2) How can I know if a certain device support multiqueus?\

3) Can anybody name some network cards which support  multiqueues?

Regards,
Kevin

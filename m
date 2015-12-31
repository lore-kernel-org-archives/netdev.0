From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: [net-next] ppp: rtnetlink device handling
Date: Thu, 31 Dec 2015 08:46:59 +0100
Message-ID: <CA+icZUVb03kO3O2nqEHazotM_Df4SLUw6SOAuPXuB3eNy_gOHg@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:35101 "EHLO
	mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbbLaHrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 02:47:00 -0500
Received: by mail-vk0-f44.google.com with SMTP id k1so86726644vkb.2
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 23:47:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guillaume,

can you explain why you moved ppp to rtnetlink device handling?
Benefits, etc.?

Does anything change when using NetworkManager/ModemManager/pppd for
my network setup/handling (here: Ubuntu/precise AMD64)?

Thanks in advance.

Regards,
- Sedat -

P.S.: Coming soon... Not (only) in the cinemas... 201*6* ;-).

[1] https://patchwork.ozlabs.org/patch/560702/
[2] https://patchwork.ozlabs.org/patch/560703/

From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [net-next] l2tp: rely on ppp layer for skb scrubbing
Date: Mon, 4 Jan 2016 08:31:36 +0100
Message-ID: <CA+icZUXbc9EOzkSChGDC-ZACEHTm4vt6LT3TVFdVHYFFacMFOw@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:36347 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbcADHbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 02:31:36 -0500
Received: by mail-vk0-f51.google.com with SMTP id f2so206040192vkb.3
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 23:31:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Built up and ran successfully on my Ubuntu/precise AMD64 box on top of
net-next.git#master up to ("c07f30ad6805: Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net") and with...

Guillaume Nault (2):
      ppp: define reusable device creation functions
      ppp: implement rtnetlink device handling

Feel free to add my...

Tested-by: Sedat Dilek <sedat.dilek@gmail.com>

- Sedat -

[1] https://patchwork.ozlabs.org/patch/561540/

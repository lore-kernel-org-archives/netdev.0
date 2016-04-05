From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: bcmgenet: cleanup for bcmgenet_xmit_frag()
Date: Mon, 4 Apr 2016 18:00:00 -0700
Message-ID: <CAGVrzcYZ8fwLy7x6Xx59VfcYen5xpfVRxRytdo9gt7r=Fucy8Q@mail.gmail.com>
References: <1459815001-91703-1-git-send-email-pgynther@google.com> <1459815001-91703-2-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36677 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbcDEBAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 21:00:40 -0400
Received: by mail-io0-f171.google.com with SMTP id q128so1342747iof.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 18:00:40 -0700 (PDT)
In-Reply-To: <1459815001-91703-2-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-04 17:10 GMT-07:00 Petri Gynther <pgynther@google.com>:
> Add frag_size = skb_frag_size(frag) and use it when needed.
>
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

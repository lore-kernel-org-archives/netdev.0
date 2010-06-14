From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 10:52:19 +0800
Message-ID: <AANLkTilNTSyvOsW-fUKK-6Re2-VgbEgnwSNTzc6ch5Hs@mail.gmail.com>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
	<20100613.181857.189703148.davem@davemloft.net> <AANLkTilf218t898mfK1jeIFtFBFE8OvAeoOIxQTnmEt3@mail.gmail.com>
	<4C1592CE.5030501@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61916 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755297Ab0FNCwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 22:52:40 -0400
Received: by vws16 with SMTP id 16so114016vws.19
        for <netdev@vger.kernel.org>; Sun, 13 Jun 2010 19:52:39 -0700 (PDT)
In-Reply-To: <4C1592CE.5030501@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 10:24 AM, YOSHIFUJI Hideaki
<yoshfuji@linux-ipv6.org> wrote:
> NIC?
>

Linux: e1000
Darwin: tun

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)

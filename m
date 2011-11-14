From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: Re: tc: deleting single entry from filter hashtable
Date: Mon, 14 Nov 2011 22:12:50 +0100
Message-ID: <CAO0uZ+_NX2vh4DGNFNXcPzg9SiUP4yvGUxFNEZMYDENk6cwJdg@mail.gmail.com>
References: <CAO0uZ+9N9zwt07EdQzz6KjGcpRT7rdmpaBvHoE0TLDXe-0kxMg@mail.gmail.com>
	<1321287325.2272.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:33477 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756378Ab1KNVMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 16:12:51 -0500
Received: by ywt32 with SMTP id 32so2647815ywt.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 13:12:50 -0800 (PST)
In-Reply-To: <1321287325.2272.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Question: Is the single deletion/modification possible? If not --
> > judging from the lack of the documentation on given subject I kindof
> > expect that it's not possible -- is there any other possibility to
> > delete at least some reasonably small subset of the hash table that
> > could be modified and recreated quickly?
>
> Not sure I understand the exact problem, but it is possible to delete a
> single filter, and add a new one.
>

That would be nice! Could you possibly show me an exact command to
remove one specific filter from the hash table? (In last post you only
demonstrated adding, which works for me, and I have problems exactly
at constructing a deletion command..)

Thanks in advance,
-mk

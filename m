From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Tue, 3 Nov 2009 21:18:49 +0800
Message-ID: <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
References: <4AEF9862.8040404@gmail.com> <20091103080022.GA6718@ff.dom.local>
	 <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
	 <20091103100538.GC6718@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:34578 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbZKCNSp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 08:18:45 -0500
Received: by pxi9 with SMTP id 9so3870052pxi.4
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 05:18:49 -0800 (PST)
In-Reply-To: <20091103100538.GC6718@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2009 at 6:05 PM, Jarek Poplawski <jarkao2@gmail.com> wro=
te:
>
> The ceil specification is controlled only by ctokens, which are alway=
s
> updated, so no such risk.
>
Nevertheless, updating tokens is necessary too.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

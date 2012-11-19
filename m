From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unable to handle paging request, arm, at aio/tcp code, only 3.6
Date: Mon, 19 Nov 2012 13:36:04 -0800
Message-ID: <1353360964.10798.88.camel@edumazet-glaptop>
References: <20121119183222.GI2068@vicerveza.homeunix.net>
	 <1353354095.10798.76.camel@edumazet-glaptop>
	 <20121119211020.GL2068@vicerveza.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:59139 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091Ab2KSVgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 16:36:07 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so922627dak.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 13:36:06 -0800 (PST)
In-Reply-To: <20121119211020.GL2068@vicerveza.homeunix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-19 at 22:10 +0100, Llu=C3=ADs Batlle i Rossell wrote:

> If it can help, I keep the vmlinux kernel with debug info.

Well, it would be better if you could try the patch ;)

Anyway bug seems pretty obvious to me.

Thanks

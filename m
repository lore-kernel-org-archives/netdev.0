From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO + splice panics in 3.7.0-rc5
Date: Sat, 01 Dec 2012 18:58:31 -0800
Message-ID: <1354417111.20109.559.camel@edumazet-glaptop>
References: <20121115222812.GA647@1wt.eu>
	 <1353023344.10798.8.camel@edumazet-glaptop> <20121201194304.GI25450@1wt.eu>
	 <20121201205227.GA28390@1wt.eu>
	 <1354398458.20109.528.camel@edumazet-glaptop>
	 <1354401121.20109.531.camel@edumazet-glaptop>
	 <20121201224044.GL25450@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:54958 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab2LBC6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 21:58:35 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so657101vby.19
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 18:58:35 -0800 (PST)
In-Reply-To: <20121201224044.GL25450@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-01 at 23:40 +0100, Willy Tarreau wrote:

> Excellent Eric, it's rock solid now both with the reproducer and with
> haproxy!  Feel free to add my Tested-By if you want.

You did a very good work, thanks again Willy.

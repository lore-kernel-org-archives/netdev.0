From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re[2]: [PATCH v7] PPTP: PPP over IPv4 (Point-to-Point
 Tunneling Protocol)
Date: Fri, 20 Aug 2010 17:59:36 +0200
Message-ID: <1282319976.2484.263.camel@edumazet-laptop>
References: <1282285499.2295.2.camel@edumazet-laptop>
	 <E1OmTW8-0002E6-00.xeb-mail-ru@f289.mail.ru>
	 <1282319459.2484.249.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46997 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab0HTP7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 11:59:41 -0400
Received: by eyg5 with SMTP id 5so2220126eyg.19
        for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 08:59:40 -0700 (PDT)
In-Reply-To: <1282319459.2484.249.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 17:51 +0200, Eric Dumazet a =C3=A9=
crit :

> Dont include "changes from v6" or include all changes (v2,v3, ...)


The usual way of documenting changes so that they dont pollute the
permanent changelog is adding text after the "---" separator :


[PATCH v8] PPTP: PPP over IPv4 (Point-to-Point Tunneling Protocol)

The fine changelog that will be stored in git

Signed-off-by: The fine author bbbb@bbbb.com
---
Hello everybody ! (not stored in git history)
Changes from v2 : the fine changes
I hope this is the last round :)

diff....

Check Documentation/SubmittingPatches  line 492






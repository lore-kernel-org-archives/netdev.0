From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH v5] ipv6: Fix problem with expired dst cache
Date: Tue, 6 Mar 2012 15:10:04 +0800
Message-ID: <CAJFZqHwFpT=tf3qa4_s8zB1jgo-jp5XfB7QSa68NpLTj43FZ0w@mail.gmail.com>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1330931762-1466-1-git-send-email-gaofeng@cn.fujitsu.com>
	<CAJFZqHy5B8dqJWXBN_hHBdf2=gYjyyjiok=B_3XqbuEEpST07A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:60582 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753205Ab2CFHKF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 02:10:05 -0500
Received: by obbuo6 with SMTP id uo6so5066129obb.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 23:10:04 -0800 (PST)
In-Reply-To: <CAJFZqHy5B8dqJWXBN_hHBdf2=gYjyyjiok=B_3XqbuEEpST07A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Calling dst_set_expires() in =A0rt6_update_expires() will double rele=
ase
> rt->dst.from?
>
> -Roy

Sorry,  Please ignore it.

From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: wrt. core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()
Date: Sun, 10 Nov 2013 19:15:35 -1000
Message-ID: <CAHo-OoyA6DXYy6Hfknd6zBXYDc1cHLT7Wp8Shj8AhRG46zshoQ@mail.gmail.com>
References: <CAHo-OoysAJRagNagE4KF-5AXyFHt+X8tahmnRfgaNhww6V-ifw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	David Decotigny <decot@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:57091 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab3KKFPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:15:36 -0500
Received: by mail-vc0-f176.google.com with SMTP id ia6so2887448vcb.21
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 21:15:36 -0800 (PST)
In-Reply-To: <CAHo-OoysAJRagNagE4KF-5AXyFHt+X8tahmnRfgaNhww6V-ifw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's the previous email on this subject.

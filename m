From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: frag: Always orphan skbs inside ip_defrag()
Date: Mon, 25 Jan 2016 21:58:25 -0800
Message-ID: <1453787905.11327.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453506552-10373-1-git-send-email-joe@ovn.org>
	 <1453512162.1223.418.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, fw@strlen.de,
	hannes@stressinduktion.org, pravin shelar <pshelar@ovn.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33968 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbcAZF63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 00:58:29 -0500
Received: by mail-pa0-f45.google.com with SMTP id uo6so94721253pac.1
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 21:58:29 -0800 (PST)
In-Reply-To: <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-25 at 17:11 -0800, Joe Stringer wrote:

> Thanks, I can roll this into a v2 (or keep as a separate patch?). I
> got sidetracked on the IPv6 side, some other issues are blocking me on
> that but I intend to continue following up there as well.

No, don't worry, I will submit this in a separate patch.

Thanks.

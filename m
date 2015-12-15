From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Tue, 15 Dec 2015 13:21:15 -0800
Message-ID: <1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com>
	 <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com>
	 <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151215161456.GA3182@1wt.eu>
	 <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151215174346.GA3187@1wt.eu>
	 <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151215194410.GB3187@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36859 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462AbbLOVVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 16:21:17 -0500
Received: by mail-pf0-f169.google.com with SMTP id o64so118031pfb.3
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 13:21:17 -0800 (PST)
In-Reply-To: <20151215194410.GB3187@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-15 at 20:44 +0100, Willy Tarreau wrote:

> Thus do you think it's worth adding a new option as Tolga proposed ?


I thought we tried hard to avoid adding the option but determined
we could not avoid it ;)

So I would simply resend the patch for another review.

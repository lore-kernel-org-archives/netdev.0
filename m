From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] tcp: better smp listener behavior
Date: Tue, 13 Oct 2015 07:17:15 -0700
Message-ID: <1444745835.21657.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <CALx6S35NOaLyqmWbgcRdV9Swm1NVVSFkoShW0ywMi7V21jhtYQ@mail.gmail.com>
	 <1444387845.27760.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56180147.6070205@iogearbox.net> <20151013092223.GE11304@distanz.ch>
	 <561CCEAD.206@iogearbox.net> <20151013100118.GG11304@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34818 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbbJMORV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 10:17:21 -0400
Received: by pabve7 with SMTP id ve7so23119877pab.2
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 07:17:21 -0700 (PDT)
In-Reply-To: <20151013100118.GG11304@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-13 at 12:01 +0200, Tobias Klauser wrote:

> csumudp6 and csumtcp6 for trafgen are now availble in the netsniff-ng
> git as of commit 19c15748 ("trafgen: Add checksum helpers for TCP/UDP
> over IPv6").

Awesome, I tested it and it is working properly.

Thanks Tobias !

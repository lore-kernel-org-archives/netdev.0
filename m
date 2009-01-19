From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: drop leftover assignment
Date: Mon, 19 Jan 2009 22:07:01 +0100
Message-ID: <200901192207.02031.florian@openwrt.org>
References: <1232058598-15811-1-git-send-email-n0-1@freewrt.org> <1232058598-15811-2-git-send-email-n0-1@freewrt.org> <20090115223008.B784E4043837@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:58490 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbZASVHO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:07:14 -0500
Received: by fg-out-1718.google.com with SMTP id 19so1400565fgg.17
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 13:07:12 -0800 (PST)
In-Reply-To: <20090115223008.B784E4043837@mail.nwl.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thursday 15 January 2009 23:29:57 Phil Sutter, vous avez =E9crit=A0:
> As the assigned value is being overwritten shortly after, it can be
> dropped and so the whole variable definition moved to the start of th=
e
> function.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

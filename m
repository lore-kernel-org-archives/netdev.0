From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: disable napi on close and restart
Date: Wed, 14 Jan 2009 18:58:25 +0100
Message-ID: <200901141858.25530.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955448-10877-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:30018 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbZANR6o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:58:44 -0500
Received: by mu-out-0910.google.com with SMTP id g7so334155muf.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 09:58:42 -0800 (PST)
In-Reply-To: <1231955448-10877-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:50:48 Phil Sutter, vous avez =E9crit=A0=
:
> Without this the driver will crash when the NIC is being restarted.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

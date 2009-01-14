From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] korina: do not stop queue here
Date: Wed, 14 Jan 2009 19:00:38 +0100
Message-ID: <200901141900.39137.florian@openwrt.org>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org> <1231955526-12600-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
To: Phil Sutter <n0-1@freewrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:42860 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbZANSBA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 13:01:00 -0500
Received: by fk-out-0910.google.com with SMTP id 18so376290fkq.5
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 10:00:58 -0800 (PST)
In-Reply-To: <1231955526-12600-1-git-send-email-n0-1@freewrt.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 January 2009 18:52:06 Phil Sutter, vous avez =E9crit=A0=
:
> Apparently this doesn't make sense. Otherwise the queue gets disabled=
 as
> soon as it's getting empty and can only be resurrected by a driver
> restart.
>
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------

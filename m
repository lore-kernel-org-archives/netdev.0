From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 8/9] phy: fixed_phy: Add gpio to determine link
 up/down.
Date: Sun, 23 Aug 2015 11:50:19 -0700
Message-ID: <55DA15EB.9090301@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35476 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbbHWSuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:50:22 -0400
Received: by obbwr7 with SMTP id wr7so96389925obb.2
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:50:21 -0700 (PDT)
In-Reply-To: <1440323220-20438-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> An SFP module may have a link up/down status pin which can be
> connection to a GPIO line of the host. Add support for reading such a=
n
> GPIO in the fixed_phy driver.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian

From: Stas Sergeev <stsp@list.ru>
Subject: Re: [Patch v2 RFT net-next 0/9] DSA port configuration and status
Date: Mon, 31 Aug 2015 17:25:54 +0300
Message-ID: <55E463F2.60205@list.ru>
References: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastien Rannou <mxs@sbrk.org>, Arnaud Ebalard <arno@natisbad.org>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp10.mail.ru ([94.100.181.92]:57336 "EHLO smtp10.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751445AbbHaO0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 10:26:01 -0400
In-Reply-To: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

31.08.2015 16:56, Andrew Lunn =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Changes since v1:
>=20
> Rewrite 9/9 so that it hopefully does not regression on
> 868a4215be9a6d80 ("net: phy: fixed_phy: handle link-down case")
>=20
> Stas, please could you test your use case.
This was actually not mine.
The change was fixing the regression reported by other people.
I have added them to CC for this e-mail.
I'll let you know if it breaks something for me.

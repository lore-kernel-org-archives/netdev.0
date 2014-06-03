From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: Use usleep_range()
Date: Mon, 02 Jun 2014 17:01:57 -0700 (PDT)
Message-ID: <20140602.170157.1949471057816808999.davem@davemloft.net>
References: <E603DC592C92B54A89CEF6B0919A0B1CAFDE223C6D@SOLO.hq.farsitecommunications.com>
	<1401548871-12352-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kevin.curtis@farsite.co.uk, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401548871-12352-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Sat, 31 May 2014 17:07:51 +0200

> Instead of using a jiffies hack we can use the standard api for delay=
s.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied, thanks.

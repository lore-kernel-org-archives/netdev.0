From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlogic: Use time_before()
Date: Thu, 22 May 2014 15:50:37 -0400 (EDT)
Message-ID: <20140522.155037.86665103961019708.davem@davemloft.net>
References: <1400693043-15786-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shahed.shaikh@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: manuel.schoelling@gmx.de
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1400693043-15786-1-git-send-email-manuel.schoelling@gmx.de>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Manuel Sch=F6lling <manuel.schoelling@gmx.de>
Date: Wed, 21 May 2014 19:24:03 +0200

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_before() instead of plain, error-prone math.
>=20
> Signed-off-by: Manuel Sch=F6lling <manuel.schoelling@gmx.de>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

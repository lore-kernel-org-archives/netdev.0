From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: ethernet: apple: drop unused variable
Date: Wed, 22 May 2013 23:43:04 -0700 (PDT)
Message-ID: <20130522.234304.993829671947428537.davem@davemloft.net>
References: <20130522.122624.266893118412034519.davem@davemloft.net>
	<1369267057-9371-1-git-send-email-emilio@elopez.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: emilio@elopez.com.ar
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369267057-9371-1-git-send-email-emilio@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Emilio L=F3pez <emilio@elopez.com.ar>
Date: Wed, 22 May 2013 20:57:35 -0300

> Commit 3b0aaef ("net: ethernet: apple: initialize variables directly"=
)
> dropped the only loop that was using i but did not remove the actual
> variable, therefore causing a warning when building. This patch drops
> the now redundant line.
>=20
> Signed-off-by: Emilio L=F3pez <emilio@elopez.com.ar>

Applied.

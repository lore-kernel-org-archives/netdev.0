From: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH 13/20] net/caif: Use kzalloc
Date: Sun, 16 May 2010 00:54:17 +0200
Message-ID: <AANLkTim4uGaZ_RDawZSrjWybdZc60_oSl1s45qrmVn--@mail.gmail.com>
References: <Pine.LNX.4.64.1005132203150.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005132203150.6282@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia@diku.dk> wrote:
>Use kzalloc rather than the combination of kmalloc and memset.

Thank you, this look good to me.
Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

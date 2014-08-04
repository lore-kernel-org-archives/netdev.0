From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath6kl: convert a driver to use module_usb_driver()
Date: Mon, 4 Aug 2014 09:13:26 +0300
Message-ID: <8738dc6aux.fsf@kamboji.qca.qualcomm.com>
References: <20140801161115.GA13979@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>,
	<ath6kl@lists.infradead.org>
To: Himangi Saraogi <himangi774@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140801161115.GA13979@himangi-Dell> (Himangi Saraogi's message
	of "Fri, 1 Aug 2014 21:41:15 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Himangi Saraogi <himangi774@gmail.com> writes:

> This converts a driver in drivers/net/* to use the
> module_usb_driver() macro which makes the code smaller and a
> bit simpler.
>
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Thanks, applied.

-- 
Kalle Valo

From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 12/30] net: No point in casting kmalloc return values in Gianfar Ethernet Driver
Date: Fri, 24 Aug 2007 02:25:09 -0500
Message-ID: <4F41C3E8-49C1-4F5A-ABB3-116853C5102C@kernel.crashing.org>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com> <c4e095af9df5ab47e7d1c8e4f3d256d74576a0c9.1187912217.git.jesper.juhl@gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932328AbXHXHXY@vger.kernel.org>
In-Reply-To: <c4e095af9df5ab47e7d1c8e4f3d256d74576a0c9.1187912217.git.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 23, 2007, at 6:59 PM, Jesper Juhl wrote:

> kmalloc() returns a void ptr, so there's no need to cast its return
> value in drivers/net/gianfar.c .
>
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

Acked-by: Kumar Gala <galak@kernel.crashing.org>

- k

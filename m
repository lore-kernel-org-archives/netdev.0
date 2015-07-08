From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: hamradio: Fix IP over bpq encapsulation.
Date: Wed, 08 Jul 2015 14:09:54 -0700 (PDT)
Message-ID: <20150708.140954.1631566627371698945.davem@davemloft.net>
References: <20150704092230.GN5255@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	stable@vger.kernel.org, ebiederm@xmission.com
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20150704092230.GN5255@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sat, 4 Jul 2015 11:22:30 +0200

> Since 1d5da757da860a6916adbf68b09e868062b4b3b8 (ax25: Stop using magic
> neighbour cache operations.) any attempt to transmit IP packets over
> a bpqether device will result in a message like "Dead loop on virtual
> device bpq0, fix it urgently!"
> 
> Fix suggested by Eric W. Biederman <ebiederm@xmission.com>.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> Cc: <stable@vger.kernel.org> # 4.1

Applied, thanks Ralf.

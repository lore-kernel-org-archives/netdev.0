From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] NET: AX.25: Stop heartbeat timer on disconnect.
Date: Wed, 15 Jul 2015 16:13:50 -0700 (PDT)
Message-ID: <20150715.161350.1694501935758582003.davem@davemloft.net>
References: <20150713093824.GA32732@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richard@rns-stearn.demon.co.uk,
	f6bvp@free.fr, thomas@osterried.de, linux-hams@vger.kernel.org,
	stable@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150713093824.GA32732@linux-mips.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 13 Jul 2015 11:38:24 +0200

> From: Richard Stearn <richard@rns-stearn.demon.co.uk>
> 
> This may result in a kernel panic.  The bug has always existed but
> somehow we've run out of luck now and it bites.
> 
> Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
> Cc: stable@vger.kernel.org	# all branches
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> ---
> v2: Correctly attribute the patch to Richard Stearn in the From: line

Applied.

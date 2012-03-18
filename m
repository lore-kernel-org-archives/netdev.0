From: Geoff Levand <geoff@infradead.org>
Subject: Re: [PATCH 2/2] drivers: net: Remove unnecessary line continuations
Date: Sat, 17 Mar 2012 18:57:52 -0700
Message-ID: <1332035872.2902.1.camel@kubuntu-11-10>
References: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com>
	 <67ad900b6f6451b5b28b004def471c9a41b1ee24.1332011552.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <67ad900b6f6451b5b28b004def471c9a41b1ee24.1332011552.git.joe@perches.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-03-17 at 12:14 -0700, Joe Perches wrote:
> Line continuations are error prone so just remove them.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/toshiba/ps3_gelic_net.c |    3 +--

Looks OK for ps3_gelic_net.  Thanks.

Acked-by: Geoff Levand <geoff@infradead.org>


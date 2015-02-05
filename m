From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: bnx2x: fix sparse warnings
Date: Thu, 05 Feb 2015 08:30:29 -0800
Message-ID: <1423153829.31870.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423151237-20746-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <ariel.elior@qlogic.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423151237-20746-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-02-05 at 15:47 +0000, Lad Prabhakar wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warnings:
> 
> bnx2x_main.c:9172:6: warning: symbol 'bnx2x_stop_ptp' was not declared. Should it be static?
> bnx2x_main.c:13321:6: warning: symbol 'bnx2x_register_phc' was not declared. Should it be static?
> bnx2x_main.c:14638:5: warning: symbol 'bnx2x_enable_ptp_packets' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---

Note there is no need to cc lkml for such patches, netdev is more than
enough.

Acked-by: Eric Dumazet <edumazet@google.com>

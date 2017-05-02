From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/3] net-SCTP: Fine-tuning for six function
 implementations
Date: Tue, 2 May 2017 09:15:10 -0400
Message-ID: <20170502131510.GA20565@hmswarspite.think-freely.org>
References: <ea9206ca-2a2f-095e-d764-3f819610d5e8@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ea9206ca-2a2f-095e-d764-3f819610d5e8@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2017 at 03:30:25PM +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 1 May 2017 15:25:05 +0200
> 
> A few update suggestions were taken into account
> from static source code analysis.
> 
> Markus Elfring (3):
>   Replace six seq_printf() calls by seq_putc()
>   Combine two seq_printf() calls into one call in sctp_remaddr_seq_show()
>   Replace four seq_printf() calls by seq_puts()
> 
>  net/sctp/proc.c | 39 ++++++++++++++++-----------------------
>  1 file changed, 16 insertions(+), 23 deletions(-)
> 
> -- 
> 2.12.2
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

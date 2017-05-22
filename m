From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 3/5] sctp: Fix a typo in a comment line in sctp_init()
Date: Mon, 22 May 2017 16:52:31 -0300
Message-ID: <20170522195231.GE4642@localhost.localdomain>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
 <9dca8ae4-fd7f-d1de-af7b-87b92bf6411a@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9dca8ae4-fd7f-d1de-af7b-87b92bf6411a@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 06:39:29PM +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 17:43:44 +0200
> 
> Add a missing character in this description.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/protocol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 5e7c8a344770..64756c42cec9 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1454,7 +1454,7 @@ static __init int sctp_init(void)
>  	}
>  
>  	/* Allocate and initialize the SCTP port hash table.
> -	 * Note that order is initalized to start at the max sized
> +	 * Note that order is initialized to start at the max sized
>  	 * table we want to support.  If we can't get that many pages
>  	 * reduce the order and try again
>  	 */
> -- 
> 2.13.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

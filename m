From: Richard Guy Briggs <rgb@tricolour.ca>
Subject: Re: [PATCH] xfrm: fix header file comment reference to struct
 xfrm_replay_state_esn
Date: Thu, 8 Sep 2016 14:42:23 -0400
Message-ID: <20160908184223.GU8132@eclipse.tricolour.ca>
References: <1473357356-31064-1-git-send-email-rgb@tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul@nohats.ca
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473357356-31064-1-git-send-email-rgb@tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/09/08, Richard Guy Briggs wrote:
> Reported-by: Paul Wouters <paul@nohats.com>

Oops, this above should read "nohats.ca".

> Signed-off-by: Richard Guy Briggs <rgb@tricolour.ca>
> ---
>  include/uapi/linux/xfrm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
> index 1433389..1fc62b2 100644
> --- a/include/uapi/linux/xfrm.h
> +++ b/include/uapi/linux/xfrm.h
> @@ -298,7 +298,7 @@ enum xfrm_attr_type_t {
>  	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
>  	XFRMA_MARK,		/* struct xfrm_mark */
>  	XFRMA_TFCPAD,		/* __u32 */
> -	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
> +	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_state_esn */
>  	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
>  	XFRMA_PROTO,		/* __u8 */
>  	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
> -- 
> 2.1.4

	slainte mhath, RGB

--
Richard Guy Briggs               --  ~\    -- ~\            <hpv.tricolour.ca>
<www.TriColour.ca>                --  \___   o \@       @       Ride yer bike!
Ottawa, ON, CANADA                  --  Lo_>__M__\\/\%__\\/\%
Vote! -- <greenparty.ca>_____GTVS6#790__(*)__(*)________(*)(*)_________________

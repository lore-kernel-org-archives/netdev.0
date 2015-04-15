From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH linux-next v3] mlx5: wrong page mask if CONFIG_ARCH_DMA_ADDR_T_64BIT
 enabled for 32Bit architectures
Date: Wed, 15 Apr 2015 08:27:23 +0300
Message-ID: <552DF6BB.5040005@mellanox.com>
References: <1429067957-9148-1-git-send-email-honli@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429067957-9148-1-git-send-email-honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/15/2015 6:19 AM, Honggang Li wrote:
> Fix(bf0bf77 mlx5: Support communicating arbitrary host page size to firmware)

This isn't the way to write the fix note, do it that way

Fixes: bf0bf77f6519 ('mlx5: Support communicating arbitrary host page 
size to firmware')

>
> Signed-off-by: Honggang Li<honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

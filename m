From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v4 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Fri, 24 Mar 2017 13:20:01 -0400
Message-ID: <32114de2-8ab7-daec-9b36-209cab0ea550@timesys.com>
References: <1489785040-26477-1-git-send-email-akshay.bhat@timesys.com>
 <1489785040-26477-2-git-send-email-akshay.bhat@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489785040-26477-2-git-send-email-akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On 03/17/2017 05:10 PM, Akshay Bhat wrote:
> This patch adds support for the Holt HI-311x CAN controller. The HI311x
> CAN controller is capable of transmitting and receiving standard data
> frames, extended data frames and remote frames. The HI311x interfaces
> with the host over SPI.
> 
> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
> 
> Signed-off-by: Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> 

If there are no further review comments can this series be applied to
can-next or does it need to wait for the next kernel release cycle (4.13)?

Thanks,
Akshay
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

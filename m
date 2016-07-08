From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] ARM: dts: NSP: Add built-in Ethernet switch nodes
Date: Fri, 8 Jul 2016 11:52:04 -0700
Message-ID: <577FF654.9050305@gmail.com>
References: <1468003735-26895-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468003735-26895-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/08/2016 11:48 AM, Florian Fainelli wrote:
> This patch series is based on Broadcom/stblinux/devicetree/next which
> contains proper support for the BCM958625HR board. To get working
> Ethernet switch and CPU Ethernet support, the following dependencies
> based on David Miller's net-next tree are required:
> 
> - Jon Mason's BGMAC/AMAC support: https://marc.info/?t=146793308300002&r=1&w=3
> - dsa/b53 support for NSP switch: https://marc.info/?l=linux-netdev&m=146800324531914&w=3

Please ignore this series, it contained patches from a previous
submission, see this one instead:
1468003769-26959-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> 
> Florian Fainelli (2):
>   ARM: dts: NSP: Add Switch Register Access Block node
>   ARM: dts: NSP: Add BCM958625HR switch ports
> 
>  arch/arm/boot/dts/bcm-nsp.dtsi    | 11 +++++++++
>  arch/arm/boot/dts/bcm958625hr.dts | 49 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 60 insertions(+)
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

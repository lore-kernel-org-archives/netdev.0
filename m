From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 1/2] net: phy: Add Cortina CS4340 driver
Date: Mon, 29 May 2017 13:28:45 -0700
Message-ID: <5617f367-9efc-f61d-9619-07ee5a6ccea2@gmail.com>
References: <1496049091-4637-1-git-send-email-bogdan.purcareata@nxp.com>
 <1496049091-4637-2-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Bogdan Purcareata <bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>, andrew-g2DYL2Zd6BY@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1496049091-4637-2-git-send-email-bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 05/29/17 à 02:11, Bogdan Purcareata a écrit :
> Add basic support for Cortina PHY drivers. Support only CS4340 for now.
> The phys are not compatible with IEEE 802.3 clause 22/45 registers.
> 
> Implement proper read_status support. The generic 10G phy driver causes
> bus register access errors.
> 
> The driver should be described using the "ethernet-phy-id" device tree
> compatible.
> 
> Signed-off-by: Bogdan Purcareata <bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

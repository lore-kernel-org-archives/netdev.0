From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v3 2/2] dt-bindings: net: Add Cortina device tree bindings
Date: Fri, 26 May 2017 15:35:54 +0200
Message-ID: <20170526133554.GD31389@lunn.ch>
References: <1495785519-1468-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495785519-1468-3-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bogdan Purcareata <bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1495785519-1468-3-git-send-email-bogdan.purcareata-3arQi8VN3Tc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +		cs4340_phy@1 {
> +			compatible = "ethernet-phy-id13e5.1002";
> +			reg = <0x10>;

The @1 and the reg value should be the same. Please change it to
cs4340_phy@10.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

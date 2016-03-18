From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] qmi_wwan: Added support for Gemalto's Cinterion PHxx
 WWAN interface
Date: Thu, 17 Mar 2016 21:10:04 -0400 (EDT)
Message-ID: <20160317.211004.825764782261738579.davem@davemloft.net>
References: <1978E4F2CF12DD4A899FA7487323EB11010836882A@A1GTOEMBXV004.gto.a3c.atos.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hans-Christoph.Schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1978E4F2CF12DD4A899FA7487323EB11010836882A-uHmIn6rc3TL7XpjMj+VyizY6JsNizA6ek7cHwXyjAIw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Schemmel Hans-Christoph <Hans-Christoph.Schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 17 Mar 2016 10:07:56 +0000

> Added support for Gemalto's Cinterion PHxx WWAN interfaces 
> by adding QMI_FIXED_INTF with Cinterion's VID and PID.
> 
> PHxx can have:
> 2 RmNet Interfaces (PID 0x0082) or
> 1 RmNet + 1 USB Audio interface (PID 0x0083).
> 
> Signed-off-by: Hans-Christoph Schemmel <hans-christoph.schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

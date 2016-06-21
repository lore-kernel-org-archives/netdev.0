From: "Machani, Yaniv" <yanivma-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCH 0/3] *** Mesh Path Selection Metric Calculation ***
Date: Tue, 21 Jun 2016 12:23:48 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD1101391CC2B1@DFRE01.ent.ti.com>
References: <1466427622-5953-1-git-send-email-maxim.altshul@ti.com>
 <20160621121905.GA4210@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, "Mishol, Guy" <guym-l0cyMroinI0@public.gmane.org>,
	"arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>,
	"Altshul, Maxim" <maxim.altshul-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160621121905.GA4210@localhost>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Yes,
TI driver have added support in our latest release (TI git).
http://software-dl.ti.com/ecs/WiLink8/R8_7/exports/release_notes_R8_7.html

Patches will be shared with mainline in the near future.

Thanks,
Yaniv Machani

-----Original Message-----
From: Bob Copeland [mailto:me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org] 
Sent: Tuesday, June 21, 2016 15:19
To: Altshul, Maxim
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org; kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org; eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org; Machani, Yaniv; Mishol, Guy; arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org; linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Subject: Re: [PATCH 0/3] *** Mesh Path Selection Metric Calculation ***

On Mon, Jun 20, 2016 at 04:00:19PM +0300, Maxim Altshul wrote:
> 2. Implements the opcode and the mechanism that reports the rates in 
> TI driver.

Does this mean TI driver will support mesh at some point?

--
Bob Copeland %% http://bobcopeland.com/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

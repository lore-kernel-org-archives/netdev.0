From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: qmi_wwan: interface #11 in Sierra Wireless MC73xx
 is not QMI
Date: Mon, 02 Jun 2014 14:00:57 -0700 (PDT)
Message-ID: <20140602.140057.19449176455949281.davem@davemloft.net>
References: <1401364296-7207-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
To: aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401364296-7207-1-git-send-email-aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Date: Thu, 29 May 2014 13:51:36 +0200

> This interface is unusable, as the cdc-wdm character device doesn't reply to
> any QMI command. Also, the out-of-tree Sierra Wireless GobiNet driver fully
> skips it.
> 
> Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

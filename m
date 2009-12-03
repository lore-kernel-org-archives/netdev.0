From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Thu, 03 Dec 2009 02:15:36 -0800 (PST)
Message-ID: <20091203.021536.35352455.davem@davemloft.net>
References: <20091202.221627.133392199.davem@davemloft.net>
	<20091202.222254.61468873.davem@davemloft.net>
	<200912031102.56903.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200912031102.56903.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date: Thu, 3 Dec 2009 11:02:56 +0100

> here's reset_resume() again.

Also doesn't apply.

davem@sunset:~/src/GIT/net-next-2.6$ git apply --check --whitespace=error-all diff
error: patch failed: drivers/net/usb/cdc_ether.c:585
error: drivers/net/usb/cdc_ether.c: patch does not apply
You have new mail in /var/mail/davem
davem@sunset:~/src/GIT/net-next-2.6$ 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH net v3 4/5] dt: cpsw: phy-handle, phy_id, and fixed-link
 are mutually exclusive
Date: Thu, 28 Apr 2016 15:43:28 +0530
Message-ID: <5721E248.6040106@ti.com>
References: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
 <1461807767-4563-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
	Andrew Goodbody <andrew.goodbody-nYQdZkeIoGZN8Ch2cx6nig@public.gmane.org>,
	Markus Brunner <systemprogrammierung.brunner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nicolas Chauvet <kwizart-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David Rivshin (Allworx)" <drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461807767-4563-1-git-send-email-drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 28 April 2016 07:12 AM, David Rivshin (Allworx) wrote:
> From: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>
> 
> The phy-handle, phy_id, and fixed-link properties are mutually exclusive,
> and only one need be specified. Make this clear in the binding doc.
> 
> Also mark the phy_id property as deprecated, as phy-handle should be
> used instead.
> 
> Signed-off-by: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>

Reviewed-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>

Regards
Mugunthan V N
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

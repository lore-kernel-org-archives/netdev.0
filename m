From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] netlink: advertise incomplete dumps
Date: Tue, 21 Jun 2011 09:05:05 +0200
Message-ID: <1308639905.3900.0.camel@jlt3.sipsolutions.net>
References: <1308570046.4322.5.camel@jlt3.sipsolutions.net>
	 <20110620.135929.942453687487758741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110620.135929.942453687487758741.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-06-20 at 13:59 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Mon, 20 Jun 2011 13:40:46 +0200
> 
> > Should we merge this through wireless? From wireless-next it'll go into
> > net-next quickly, but the converse isn't true, so using it in wireless
> > would be harder if it was merged through net-next I think? Or John can
> > cherry-pick into wireless-testing?
> 
> I'm fine with this going in via the wireless tree, that way we'll
> see a real user when it merged into net-next-2.6

Thomas said he also has updated some of the core netlink code, but I'll
also have a real user ready and the NFC subsystem is also using it and
those are coming in through wireless. Thanks!

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

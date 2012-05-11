From: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] wlcore: wlcore should depend on MAC80211
Date: Fri, 11 May 2012 08:06:50 +0300
Message-ID: <1336712810.12189.146.camel@cumari.coelho.fi>
References: <1336711194-26883-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1336711194-26883-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-05-11 at 06:39 +0200, Sasha Levin wrote:
> wlcore can't be built if MAC80211 isn't set.
> 
> Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---

Thanks for your patch, Sasha! But this change was already submitted and
has been applied in the wl12xx.git tree.  I've sent a pull request with
it already, but it hasn't been pulled into wireless-next and up.

http://www.spinics.net/lists/linux-next/msg19910.html
http://www.spinics.net/lists/linux-wireless/msg89583.html

-- 
Cheers,
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

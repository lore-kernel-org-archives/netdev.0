From: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [2.6.31-rc1] iwlagn (4965): no wireless due to RFKILL problem
Date: Fri, 26 Jun 2009 13:59:10 +0200
Message-ID: <8db1092f0906260459n308311faweb6d9733cdd1eb13@mail.gmail.com>
References: <200906261336.29318.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200906261336.29318.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/26 Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>:
> I've tried .31-rc1 on my HP 2510p notebook and the only problem I found
> was that wireless no longer works. The cause looks to be related to
> RFKILL.
>

Same on HP/Compaq nx6310, caused by hp-wmi module. It's disable
bluetooth and wireless. I must turn it on in Windows XP (in HP tools).
Workaround: don't load hp-wmi. Already I try find how enable it via
/sys like in Windows.

-- 
Maciej Rutecki
http://www.maciek.unixy.pl
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

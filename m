From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 1/1] rtlwifi: Convert drivers to use new API for ieee80211_is_robust_mgmt_frame()
Date: Sat, 22 Feb 2014 11:19:58 -0600
Message-ID: <5308DC3E.8000501@lwfinger.net>
References: <1393089433-28270-1-git-send-email-Larry.Finger@lwfinger.net> <1393089433-28270-18-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393089433-28270-18-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/22/2014 11:17 AM, Larry Finger wrote:
> Drivers rtl8188ee, rtl8192ce, rtl8192se, and rtl8723ae all use this routine.
> In addition, all callers of ieee80211_is_robust_mgmt_frame() have access to the
> skb. Thus, it is trivial to use the new API rather than the underscored old version.
>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> ---

John and Johannes,

Ignore this one. It was sent by mistake.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

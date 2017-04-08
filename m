From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Sat, 08 Apr 2017 20:37:50 +0200
Message-ID: <1491676670.5800.25.camel@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
         <20170408174900.12820-2-johannes@sipsolutions.net>
         <14c58480-cd03-4d61-fffa-fab6e437a7ea@cumulusnetworks.com>
         (sfid-20170408_203643_247519_552A8ABE)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <14c58480-cd03-4d61-fffa-fab6e437a7ea-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org> (sfid-20170408_203643_247519_552A8ABE)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-04-08 at 14:36 -0400, David Ahern wrote:
> 
> I think v3 is in your future ...
> 
> /home/dsa/kernel-4.git/include/linux/netlink.h:78:12: error:
> ‘NETLINK_MAX_COOKIE_LEN’ undeclared here (not in a function)
>   u8 cookie[NETLINK_MAX_COOKIE_LEN];
>             ^
> 
> it's defined in patch 3; needed in patch 1

Damn. Ok, that'll have to wait until Monday, unless the airport has
useful wifi.

johannes

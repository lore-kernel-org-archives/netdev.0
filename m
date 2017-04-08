From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH v3 0/5] netlink extended ACK reporting
Date: Sat,  8 Apr 2017 22:24:29 +0200
Message-ID: <20170408202434.12018-1-johannes@sipsolutions.net>
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changes since v2:
 * add NUM_NLMSGERR_ATTRS, NLMSGERR_ATTR_MAX
 * fix cookie length to 20 (sha-1 length)
 * move struct members for cookie to patch 3 where they should be
 * another cleanup suggested by David Ahern

johannes

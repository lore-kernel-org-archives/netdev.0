From: "McMillan, Scott A" <scott.a.mcmillan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH] man: packet.7: document fanout, ring and auxiliary
 options
Date: Fri, 29 Mar 2013 15:02:24 +0000
Message-ID: <3E1EA20FF626AF48A6AB8DB7754BB3E524350980@FMSMSX104.amr.corp.intel.com>
References: <CA+FuTScjf2nkPykOkscuWXMuUSfAhDtQGCBhByxcyJ_cSsOPcQ@mail.gmail.com>
 <1364563798-20221-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org" <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	"johann.baudy-1YmjpbiIw0bR7s880joybQ@public.gmane.org" <johann.baudy-1YmjpbiIw0bR7s880joybQ@public.gmane.org>,
	"herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org" <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364563798-20221-1-git-send-email-willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>If you are on the CC: list, then you are the author of one of the commits referred to in this manpage. If you can, please check whether my description of your change is correct. Thanks.

>+.BR PACKET_TIMESTAMP " (with PACKET_RX_RING)"
>+.\" commit 614f60fa9d73a9e8fdff3df83381907fea7c5649
>+The packet receive ring always stores a timestamp in the metadata header.
>+By default, this is a software generated timestamp generated when the 
>+packet is copied into the ring.
>+This integer option selects the type of timestamp.
>+Besides the default, it support the two hardware formats described in 
>+.IR Documentation/networking/timestamping.txt
>+in the Linux kernel source tree.

Acked-by: Scott McMillan <scott.a.mcmillan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

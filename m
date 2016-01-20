From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Thu, 21 Jan 2016 00:24:40 +0200
Message-ID: <CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453318816-21672-1-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 20, 2016 at 9:40 PM, Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:

> Changes since v2:
[...]
>                 *move netlink patch up

I also asked you why the port mapper code has to be present in each
iwarp driver and not part of the IB core stack, and you responded
"i40iw iwarp driver registers with port mapper and uses its services.
Beside that it is not the scope of the patch series"  -- well, it is
in the scope of upstream review to pose such questions, please
address.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

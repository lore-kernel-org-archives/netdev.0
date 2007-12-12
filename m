From: "Joonwoo Park" <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] [net/wireless/iwlwifi] : iwlwifi 3945 Fix raceconditional panic.
Date: Wed, 12 Dec 2007 23:41:24 +0900
Message-ID: <b25c3fa70712120641l1fcf4447u2501cc8539396cf3@mail.gmail.com>
References: <00e501c831ab$2e78daa0$9c94fea9@jason>
	 <1196298656.7614.77.camel@debian.sh.intel.com>
	 <016401c83229$3302d250$9c94fea9@jason>
	 <20071212034325.4a022320.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Zhu Yi" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071212034325.4a022320.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2007/12/12, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>:
>
> Did drivers/net/wireless/iwlwifi/iwl4965-base.c get fixed in a simlar
> fashion?
>

Hi Andrew,
Both of them was applied to mainline.

commit 3ae6a054553ee8b7f74bf7de8904022b26705778
Author: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Nov 29 10:43:16 2007 +0900

    iwlwifi 4965 Fix race conditional panic.

    Signed-off-by: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

commit e47eb6ad41e8fc4c2696665512b70d1fd4cf3f22
Author: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Thu Nov 29 10:42:49 2007 +0900

    iwlwifi 3945 Fix race conditional panic.

    Signed-off-by: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Thanks,
Joonwoo

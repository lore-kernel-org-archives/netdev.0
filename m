From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2016-09-15
Date: Sat, 17 Sep 2016 09:54:27 -0400 (EDT)
Message-ID: <20160917.095427.639883783043129882.davem@davemloft.net>
References: <87zin99p3y.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87zin99p3y.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Thu, 15 Sep 2016 18:09:21 +0300

> here's the first pull request for 4.9. The ones I want to point out are
> the FIELD_PREP() and FIELD_GET() macros added to bitfield.h, which are
> reviewed by Linus, and make it possible to remove util.h from mt7601u.
> 
> Also we have new HW support to various drivers and other smaller
> features, the signed tag below contains more information. And I pulled
> my ath-current (uses older net tree as the baseline) branch to fix a
> conflict in ath10k.
> 
> Once again the diffstat from git request-pull was wrong. I fixed it by
> manually copying the diffstat from a test pull against net-next, so
> everything should be ok. But please let me know if there are any
> problems.

Pulled, thanks Kalle.

From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/6] iw_cxgb3: Bug Fixes for 2.6.23
Date: Wed, 27 Jun 2007 14:31:55 -0500
Message-ID: <4682BB2B.7030002@opengridcomputing.com>
References: <20070627155119.24944.44172.stgit@dell3.ogc.int> <adafy4dryzf.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, divy@chelsio.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]:36598 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751250AbXF0Tby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 15:31:54 -0400
In-Reply-To: <adafy4dryzf.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > Here are some bug fixes to the iw_cxgb3 driver that I'd like included
>  > for 2.6.23. NOTE: Patch 1 requires a firmware interface change, so
>  > there is a version bump to 4.3 included in that patch that hits cxgb3.
>  > This will likely conflict with a previous version change that is in
>  > Jeff's upstream branch.  The net is: we need the firmware version bumped
>  > to 4.3 with these iw_cxgb3 changes.
> 
> OK, I'll probably pull this into my tree and hold off on asking Linus
> to pull until after he pulls Jeff's net driver tree.  Once that
> happens I'll fix up any conflicts and ask Linus to pull.

Sounds good.

Thanks,

Steve.

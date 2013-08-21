From: Hyong-Youb Kim <hykim@myri.com>
Subject: Re: [PATCH net-next] myri10ge: Add support for ndo_busy_poll
Date: Tue, 20 Aug 2013 19:56:54 -0700 (PDT)
Message-ID: <Pine.GSO.4.44.1308201952530.11957-100000@creator>
References: <20130820.150905.44199510198057625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-43-81-194.west.biz.rr.com ([24.43.81.194]:1875 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751977Ab3HUC5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 22:57:12 -0400
In-Reply-To: <20130820.150905.44199510198057625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 20 Aug 2013, David Miller wrote:

> From: Hyong-Youb Kim <hykim@myri.com>
> Date: Mon, 19 Aug 2013 02:02:19 -0700
>
> > Add the ndo_busy_poll handler. Use skb_mark_napi_id to mark receive
[...]
> > Signed-off-by: Hyong-Youb Kim <hykim@myri.com>
>
> Applied, but this patch had a ton of trailing whitespace which I had
> to fix up.
>

Thanks.  About whitespace on empty lines, it is my bad.  Did not run
checkpatch.  Will do a better job next time.

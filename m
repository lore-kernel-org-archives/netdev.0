From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] net: netcp: fix check of requested timestamping
 filter
Date: Mon, 15 May 2017 15:21:30 -0400 (EDT)
Message-ID: <20170515.152130.1349542624120816980.davem@redhat.com>
References: <20170515140436.12175-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, w-kwok2@ti.com, richardcochran@gmail.com
To: mlichvar@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934329AbdEOTVd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 15:21:33 -0400
In-Reply-To: <20170515140436.12175-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miroslav Lichvar <mlichvar@redhat.com>
Date: Mon, 15 May 2017 16:04:36 +0200

> The driver doesn't support timestamping of all received packets and
> should return error when trying to enable the HWTSTAMP_FILTER_ALL
> filter.
> 
> Cc: WingMan Kwok <w-kwok2@ti.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Applied, thank you.

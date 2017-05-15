From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net] net: netcp: fix check of requested timestamping
 filter
Date: Mon, 15 May 2017 17:03:36 +0200
Message-ID: <20170515150336.GA14554@localhost.localdomain>
References: <20170515140436.12175-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34823 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934147AbdEOPDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 11:03:52 -0400
Received: by mail-wm0-f50.google.com with SMTP id b84so88063748wmh.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 08:03:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170515140436.12175-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 04:04:36PM +0200, Miroslav Lichvar wrote:
> The driver doesn't support timestamping of all received packets and
> should return error when trying to enable the HWTSTAMP_FILTER_ALL
> filter.
> 
> Cc: WingMan Kwok <w-kwok2@ti.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>

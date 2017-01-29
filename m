From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 29 Jan 2017 21:51:56 +0100
Message-ID: <20170129205156.GA30336@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153134.GC2223@localhost.localdomain>
 <BL2PR07MB23065AC5421859AAC6D334348D480@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35112 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbdA2UwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 15:52:02 -0500
Received: by mail-wm0-f67.google.com with SMTP id u63so4484872wmu.2
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 12:52:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23065AC5421859AAC6D334348D480@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 29, 2017 at 05:26:13PM +0000, Mintz, Yuval wrote:
> We could - but what difference would it make?

It would reduce the chance of missing the next time stamp.

Thanks,
Richard

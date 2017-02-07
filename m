From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] qed: Add infrastructure for PTP support.
Date: Tue, 7 Feb 2017 07:44:40 +0100
Message-ID: <20170207064440.GA1853@localhost.localdomain>
References: <1485848869-22834-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485848869-22834-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170202125637.GA3191@netboy>
 <BL2PR07MB2306F69350DA91B9B2A2E3588D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB2306BFF942FD6EE54400D1288D400@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34711 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdBGGot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 01:44:49 -0500
Received: by mail-wr0-f194.google.com with SMTP id 89so4809539wrr.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 22:44:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306BFF942FD6EE54400D1288D400@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2017 at 10:41:44AM +0000, Mintz, Yuval wrote:
> Richard - we're planning on sending v4 with the existing algorithm
> [but without iterating on 'val == 0']; If you have any suggestion for
> improving this, please share it.

Sorry, haven't had the time to look at your issue.

BTW, you said you think the performance impact is small, but did you
measure it on typical HW?

Thanks,
Richard

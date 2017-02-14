From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v6 0/2] qed*: Add support for PTP
Date: Tue, 14 Feb 2017 19:30:12 +0100
Message-ID: <20170214183012.GA26814@localhost.localdomain>
References: <1487088205-21578-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Sudarsana.Kalluru@cavium.com
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35246 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdBNSaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:30:22 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so28652102wra.2
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 10:30:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1487088205-21578-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 06:03:23PM +0200, Yuval Mintz wrote:
> This patch series adds required changes for qed/qede drivers for
> supporting the IEEE Precision Time Protocol (PTP).
> 
> Dave,
> Please consider applying this series to "net-next".
> 
> Thanks,
> Yuval
> 
> Changes from previous versions:
> -------------------------------
> v6: Corrected broken loop iteration in previous version.
>     Reduced approximation error of adjfreq.

This version of adjfreq() is greatly improved, thanks!

For the series:

Acked-by: Richard Cochran <richardcochran@gmail.com>

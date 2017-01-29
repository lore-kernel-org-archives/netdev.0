From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 0/2] qed*: Add support for PTP
Date: Sun, 29 Jan 2017 16:09:42 +0100
Message-ID: <20170129150942.GA2223@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36289 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750978AbdA2PKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 10:10:40 -0500
Received: by mail-wm0-f65.google.com with SMTP id r126so71233045wmr.3
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 07:09:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 11:28:21PM -0800, Sudarsana Kalluru wrote:
> From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
> 
> Hi David,
>     The patch series adds required changes for qed/qede drivers for
> supporting the IEEE Precision Time Protocol (PTP).
> 
> Changes from previous versions:
> -------------------------------
> v2: Use do_div for 64-bit divisions
> 
> 
> Please consider applying this series to "net-next".

Can we please, PLEASE put the PHC maintainer onto CC when posting new
PHC drivers?

Thanks,
Richard

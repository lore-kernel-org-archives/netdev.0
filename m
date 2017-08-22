From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: make ptp_clock_info const
Date: Tue, 22 Aug 2017 08:27:30 +0200
Message-ID: <20170822062730.u2zj7qumzjcl4f6o@localhost>
References: <1503336672-22918-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:33230 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754446AbdHVG1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 02:27:42 -0400
Content-Disposition: inline
In-Reply-To: <1503336672-22918-1-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 11:01:12PM +0530, Bhumika Goyal wrote:
> File ptp_ixp46x.c is not tested as I could not find any architecture
> to cross compile it. 

No problem.  Thanks for test compiling the other drivers.

Acked-by: Richard Cochran <richardcochran@gmail.com>

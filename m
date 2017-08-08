From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/2] wlcore: add const to bin_attribute structure
Date: Tue,  8 Aug 2017 11:52:52 +0000 (UTC)
Message-ID: <20170808115252.6DD2260209@smtp.codeaurora.org>
References: <1501696634-15765-2-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, Bhumika Goyal <bhumirks@gmail.com>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51486 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751880AbdHHLww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 07:52:52 -0400
In-Reply-To: <1501696634-15765-2-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bhumika Goyal <bhumirks@gmail.com> wrote:

> Add const to bin_attribute structure as it is only passed to the
> functions sysfs_{remove/create}_bin_file. The corresponding arguments
> are of type const, so declare the structure to be const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

4f2949febc22 wlcore: add const to bin_attribute structure

-- 
https://patchwork.kernel.org/patch/9877341/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

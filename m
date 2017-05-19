From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: add missing USB-descriptor endianness conversion
Date: Fri, 19 May 2017 06:03:26 +0000 (UTC)
Message-ID: <20170519060326.C4CC46085D@smtp.codeaurora.org>
References: <20170512101555.2111-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47318 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751871AbdESGD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 02:03:27 -0400
In-Reply-To: <20170512101555.2111-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johan Hovold <johan@kernel.org> wrote:
> Add the missing endianness conversions to a debug statement printing
> the USB device-descriptor bcdUSB field during probe.
> 
> Signed-off-by: Johan Hovold <johan@kernel.org>

Patch applied to wireless-drivers-next.git, thanks.

a1ad7198202f mwifiex: add missing USB-descriptor endianness conversion

-- 
https://patchwork.kernel.org/patch/9723847/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

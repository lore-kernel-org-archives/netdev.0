From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next #2 35/39] myri10ge: stop using net_device.{base_addr,
 irq}.
Date: Fri, 06 Apr 2012 07:48:31 -0400
Message-ID: <4F7ED80F.9050808@myri.com>
References: <1333704408.git.romieu@fr.zoreil.com> <a5a6d0922ea55d7c8e7792633135e8cb94ccd1c2.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jon Mason <mason@myri.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:48901 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756356Ab2DFLse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 07:48:34 -0400
Received: by qcro28 with SMTP id o28so1390779qcr.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 04:48:33 -0700 (PDT)
In-Reply-To: <a5a6d0922ea55d7c8e7792633135e8cb94ccd1c2.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/12 06:06, Francois Romieu wrote:
> Signed-off-by: Francois Romieu<romieu@fr.zoreil.com>
> Cc: Jon Mason<mason@myri.com>
> Cc: Andrew Gallatin<gallatin@myri.com>
> ---
>   drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    7 ++-----
>   1 files changed, 2 insertions(+), 5 deletions(-)
>

Acked-by: Andrew Gallatin<gallatin@myri.com>

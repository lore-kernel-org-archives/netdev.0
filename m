From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] e1000e: Include clocksource.h to get CLOCKSOURCE_MASK.
Date: Wed, 31 Dec 2014 15:42:13 -0800
Message-ID: <CAL3LdT50rDtJKf8dVh_Gz-Z-41QUbZcwrCDBNE8dp0VgAQM3pg@mail.gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41739 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbaLaXmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 18:42:13 -0500
Received: by mail-ob0-f174.google.com with SMTP id nt9so55057135obb.5
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 15:42:13 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 3:33 PM, David Miller <davem@davemloft.net> wrote:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 1 +
>  1 file changed, 1 insertion(+)

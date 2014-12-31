From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] igb_ptp: Include clocksource.h to get CLOCKSOURCE_MASK.
Date: Wed, 31 Dec 2014 15:43:16 -0800
Message-ID: <CAL3LdT42x2Vvg6rVGz_Hp5vFcxnu2QYHO1daeNdvvdn5HBnniA@mail.gmail.com>
References: <20141231.183359.681102444156146233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:52933 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaLaXnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 18:43:17 -0500
Received: by mail-ob0-f171.google.com with SMTP id uz6so49735609obc.2
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 15:43:16 -0800 (PST)
In-Reply-To: <20141231.183359.681102444156146233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 3:33 PM, David Miller <davem@davemloft.net> wrote:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c | 1 +
>  1 file changed, 1 insertion(+)
>

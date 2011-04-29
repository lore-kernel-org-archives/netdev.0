From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: cancel timer on device removal
Date: Fri, 29 Apr 2011 12:33:00 -0700 (PDT)
Message-ID: <20110429.123300.70199929.davem@davemloft.net>
References: <1303849811-29025-1-git-send-email-nhorman@tuxdriver.com>
	<1304104851.12355.125.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58800
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750755Ab1D2Tdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 15:33:33 -0400
In-Reply-To: <1304104851.12355.125.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 29 Apr 2011 12:20:51 -0700

> 
> On Tue, 2011-04-26 at 13:30 -0700, Neil Horman wrote:
>> Fix the problem by ensuring that the timer is stopped when
>> pci_device_unregister
>> is called.
>> 
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> Reported-by: Hushan Jia <hjia@redhat.com>
>> CC: Michael Chan <mchan@broadcom.com>
>> CC: "David S. Miller" <davem@davemloft.net>
> 
> Thanks Neil.
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks everyone.

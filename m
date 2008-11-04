From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH]: net/: Kill now superfluous ->last_rx stores.
Date: Tue, 4 Nov 2008 07:14:59 +0100
Message-ID: <EA788924-7447-4877-B68B-48F4E66C3B55@holtmann.org>
References: <20081103.220145.73307270.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35612 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883AbYKDGPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 01:15:05 -0500
In-Reply-To: <20081103.220145.73307270.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> net/: Kill now superfluous ->last_rx stores.
>
> The generic packet receive code takes care of setting
> netdev->last_rx when necessary, for the sake of the
> bonding ARP monitor.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

just for the sake of it, the Bluetooth part is fine with :)

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


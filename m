From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] qed: add support for dcbx.
Date: Tue, 17 May 2016 12:30:32 -0400 (EDT)
Message-ID: <20160517.123032.1612200744316036123.davem@davemloft.net>
References: <1463481866-4007-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbcEQQaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 12:30:39 -0400
In-Reply-To: <1463481866-4007-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Tue, 17 May 2016 06:44:26 -0400

> This patch adds the necessary driver support for Management Firmware to
> configure the device/firmware with the dcbx results. Management Firmware
> is responsible for communicating the DCBX and driving the negotiation,
> but the driver has responsibility of receiving async notification and
> configuring the results in hw/fw. This patch also adds the dcbx support for
> future protocols (e.g., FCoE) as preparation to their imminent submission.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.

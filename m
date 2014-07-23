From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [ethtool PATCH 1/1] ethtool: Support cpsw ale-table registers
 in -d
Date: Wed, 23 Jul 2014 15:05:48 +0530
Message-ID: <53CF81F4.8020506@ti.com>
References: <1406107764-1737-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:44494 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbaGWJgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 05:36:01 -0400
In-Reply-To: <1406107764-1737-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 July 2014 02:59 PM, Mugunthan V N wrote:
> CPSW ale-table contains useful details of the MAC address added to the
> table and learnt by the device. This dumps them with the -d option.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
The driver patch is already there in net-next, commit id is
52c4f0ec662bbf02f1b0bcb311a48af2c8e5ee89

Regards
Mugunthan V N

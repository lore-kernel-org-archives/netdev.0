From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] bnx2: Support secondary MAC addresses.
Date: Mon, 14 Jul 2008 22:39:59 -0700 (PDT)
Message-ID: <20080714.223959.251904044.davem@davemloft.net>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
	<1215739755-5495-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753101AbYGOFj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:39:59 -0400
In-Reply-To: <1215739755-5495-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Jul 2008 18:29:14 -0700

> Add support for configuring secondary unicast addresses.  There
> are 4 additional perfect match filters which can be used for
> secondary unicast address support.
> 
>   *  Modified bnx2_set_mac_addr() to be more generic in handling
>      the setting of the perfect match filters
>   *  Changed bnx2_set_rx_mode() to handle the unicast dev_addr_list
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

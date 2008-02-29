From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/4][ATM]: Use seq_open/release_privade
 instead of manual manipulations.
Date: Fri, 29 Feb 2008 11:37:37 -0800 (PST)
Message-ID: <20080229.113737.09846193.davem@davemloft.net>
References: <47C80C74.4010309@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48215
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751637AbYB2Thi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:37:38 -0500
In-Reply-To: <47C80C74.4010309@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 29 Feb 2008 16:45:24 +0300

> lec_seq_open/lec_seq_release and __vcc_seq_open/vcc_seq_release
> do seq_open/release_private's job.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.26, thanks.

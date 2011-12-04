From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 performance?
Date: Mon, 5 Dec 2011 00:40:04 +0100
Message-ID: <20111204234004.GA32515@electric-eye.fr.zoreil.com>
References: <20111204211007.GA32098@hiwaay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>
To: Chris Adams <cmadams@hiwaay.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34273 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244Ab1LDXqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 18:46:49 -0500
Content-Disposition: inline
In-Reply-To: <20111204211007.GA32098@hiwaay.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Adams <cmadams@hiwaay.net> :
[...]
> Are there any suggestions for what I might be able to do to improve
> throughput?  Is there a driver issue, or is it in how the motherboard
> implemented the NIC ?

Can you grep for the r8169 lines in the dmesg of both computers and
send the XID lines ?

It should show if the nics are the same or not.

-- 
Ueimor

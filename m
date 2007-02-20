From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFT] sky2 auto negotiation PHY errata
Date: Tue, 20 Feb 2007 11:00:53 -0800
Message-ID: <20070220110053.74f26b4d@localhost>
References: <20070202112846.31acaa03@freekitty>
	<20070220184212.GC30164@robsims.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rob Sims <rob@robsims.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44079 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030424AbXBTTBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:01:16 -0500
In-Reply-To: <20070220184212.GC30164@robsims.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You need the flow control fix and the tx_timeout fix posted for 2.6.20 (stable)
and current git tree. 

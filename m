From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 6/9] jme: Safer MAC processor reset
 sequence
Date: Sun, 13 Feb 2011 20:44:32 -0800 (PST)
Message-ID: <20110213.204432.135513838.davem@davemloft.net>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
	<1297657662-30289-6-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arieslee@jmicron.com,
	devinchiu@jmicron.com, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36890
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755145Ab1BNEn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 23:43:56 -0500
In-Reply-To: <1297657662-30289-6-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Mon, 14 Feb 2011 12:27:39 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> Adding control to clk_rx, and makes the control of clk_{rx|tx|tcp}
> with safer sequence.
> This sequence is provided by JMicron.
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.

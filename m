From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] jme: Don't show UDP Checksum error if
 HW misjudged
Date: Sun, 13 Feb 2011 21:44:52 -0800 (PST)
Message-ID: <20110213.214452.209982682.davem@davemloft.net>
References: <1297661238-1467-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arieslee@jmicron.com,
	devinchiu@jmicron.com, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751000Ab1BNFoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 00:44:17 -0500
In-Reply-To: <1297661238-1467-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Mon, 14 Feb 2011 13:27:17 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> Some JMicron Chip treat 0 as error checksum for UDP packets.
> Which should be "No checksum needed".
> 
> Reported-by: Adam Swift <Adam.Swift@omnitude.net>
> Confirmed-by: "Aries Lee" <arieslee@jmicron.com>
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.

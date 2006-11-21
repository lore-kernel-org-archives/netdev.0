From: David Miller <davem@davemloft.net>
Subject: Re: [BRIDGE] netlink: Convert bridge netlink code to new netlink
 interface
Date: Mon, 20 Nov 2006 16:20:37 -0800 (PST)
Message-ID: <20061120.162037.41877867.davem@davemloft.net>
References: <20061119171002.GH8693@postel.suug.ch>
	<20061120101317.5c411c3c@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:30182
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966888AbWKUAUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 19:20:34 -0500
To: shemminger@osdl.org
In-Reply-To: <20061120101317.5c411c3c@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 20 Nov 2006 10:13:17 -0800

> On Sun, 19 Nov 2006 18:10:02 +0100
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > Removes dependency on buggy rta_buf, fixes a memory corruption bug due to
> > a unvalidated netlink attribute, and simplifies the code.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Looks fine, please put in 2.6.20

Done, thanks everyone.

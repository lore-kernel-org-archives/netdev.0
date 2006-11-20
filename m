From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BRIDGE] netlink: Convert bridge netlink code to new netlink
 interface
Date: Mon, 20 Nov 2006 10:13:17 -0800
Message-ID: <20061120101317.5c411c3c@freekitty>
References: <20061119171002.GH8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:63630 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S966342AbWKTSN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 13:13:28 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061119171002.GH8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 19 Nov 2006 18:10:02 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Removes dependency on buggy rta_buf, fixes a memory corruption bug due to
> a unvalidated netlink attribute, and simplifies the code.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks fine, please put in 2.6.20

From: David Miller <davem@davemloft.net>
Subject: Re: [MACVLAN]: Prevent nesting macvlan devices
Date: Thu, 10 Jan 2008 22:39:54 -0800 (PST)
Message-ID: <20080110.223954.252566228.davem@davemloft.net>
References: <47863A96.5080708@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751978AbYAKGjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:39:55 -0500
In-Reply-To: <47863A96.5080708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 10 Jan 2008 16:32:38 +0100

> [MACVLAN]: Prevent nesting macvlan devices
> 
> Don't allow to nest macvlan devices since it will cause lockdep warnings and
> isn't really useful for anything.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.

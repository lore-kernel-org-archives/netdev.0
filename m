From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPV4] Remove unused member of dst_entry
Date: Mon, 07 Jan 2008 22:37:04 -0800 (PST)
Message-ID: <20080107.223704.230287255.davem@davemloft.net>
References: <eb3ff54b0801060215g55cf862ja793400f060b9e34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753993AbYAHGhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:37:04 -0500
In-Reply-To: <eb3ff54b0801060215g55cf862ja793400f060b9e34@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Sun, 6 Jan 2008 12:15:35 +0200

>   The info placeholder member of dst_entry seems to be unused in the
> network stack.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.

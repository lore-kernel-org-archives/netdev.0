From: David Miller <davem@davemloft.net>
Subject: Re: macvlan: fix gso_max_size setting
Date: Mon, 23 Nov 2009 10:10:13 -0800 (PST)
Message-ID: <20091123.101013.40629093.davem@davemloft.net>
References: <4B0A64E2.8090203@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59048
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbZKWSJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:09:55 -0500
In-Reply-To: <4B0A64E2.8090203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 23 Nov 2009 11:33:06 +0100

> Fix macvlan gso_max_size setting. Based on net-next-2.6.git.

Pretty serious defect, maybe net-2.6 material?

If someone hits this, it's going to trigger something awful.


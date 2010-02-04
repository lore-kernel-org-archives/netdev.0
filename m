From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] qlge: Add check for eeh failure when
 closing device.
Date: Wed, 03 Feb 2010 20:06:16 -0800 (PST)
Message-ID: <20100203.200616.254837672.davem@davemloft.net>
References: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
	<1265217853-26959-3-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56870
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756271Ab0BDEGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:06:03 -0500
In-Reply-To: <1265217853-26959-3-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed,  3 Feb 2010 09:24:12 -0800

> Fix crash where resources are freed twice on an eeh recovery failure.
> If eeh recovery fails we set a flag to indicate to close() that
> resources have been freed.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.

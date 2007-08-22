From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/16] [XFRM] netlink: Move algorithm length
 calculation to its own function
Date: Wed, 22 Aug 2007 13:56:34 -0700 (PDT)
Message-ID: <20070822.135634.75781429.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145630.629135129@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42780
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933641AbXHVU4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:56:35 -0400
In-Reply-To: <20070822145630.629135129@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:44 +0200

> Adds alg_len() to calculate the properly padded length of an
> algorithm attribute to simplify the code.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/16] [XFRM] netlink: Establish an attribute policy
Date: Wed, 22 Aug 2007 13:59:12 -0700 (PDT)
Message-ID: <20070822.135912.133765946.davem@davemloft.net>
References: <20070822145538.861270927@lsx.localdomain>
	<20070822145631.206110433@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42792
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754738AbXHVU7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 16:59:14 -0400
In-Reply-To: <20070822145631.206110433@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 22 Aug 2007 16:55:48 +0200

> Adds a policy defining the minimal payload lengths for all the attributes
> allowing for most attribute validation checks to be removed from in
> the middle of the code path. Makes updates more consistent as many format
> errors are recognised earlier, before any changes have been attempted.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.

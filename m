From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] switchdev: add support for fdb
 add/del/dump via switchdev_port_obj ops.
Date: Sun, 17 May 2015 22:49:29 -0400 (EDT)
Message-ID: <20150517.224929.902285900190721427.davem@davemloft.net>
References: <1431579343-21457-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbERCtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 22:49:31 -0400
In-Reply-To: <1431579343-21457-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Date: Wed, 13 May 2015 21:55:43 -0700

> - introduce port fdb obj and generic switchdev_port_fdb_add/del/dump()
> - use switchdev_port_fdb_add/del/dump in rocker/team/bonding ndo ops.
> - add support for fdb obj in switchdev_port_obj_add/del/dump()
> - switch rocker to implement fdb ops via switchdev_ops
> 
> v3: updated to sync with named union changes.
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks.

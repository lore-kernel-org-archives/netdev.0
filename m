From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 1/9] mlxsw: pci: Add resources query
 implementation.
Date: Thu, 21 Jul 2016 11:25:35 +0300
Message-ID: <20160721082535.GB11902@colbert.mtl.com>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
 <1469089160-4239-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<yotamg@mellanox.com>, <eladr@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0043.outbound.protection.outlook.com ([104.47.2.43]:31604
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751529AbcGUJ7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 05:59:49 -0400
Content-Disposition: inline
In-Reply-To: <1469089160-4239-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 21, 2016 at 11:19:12AM IDT, jiri@resnulli.us wrote:
>From: Nogah Frankel <nogahf@mellanox.com>
>
>Add resources query implementation. If exists, query the HW for its
>builtin resources instead of having them as consts in the code.
>
>Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/9] mlxsw: pci: Add resources query
 implementation.
Date: Fri, 22 Jul 2016 21:17:53 +0200
Message-ID: <20160722191753.GA2050@nanopsycho.orion>
References: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
 <1469095397-3837-2-git-send-email-jiri@resnulli.us>
 <d8da3a59-34a8-e287-103e-c236f66aad3d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
	eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, jhs@mojatatu.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36600 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbcGVTR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 15:17:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id x83so7322436wma.3
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 12:17:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d8da3a59-34a8-e287-103e-c236f66aad3d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 22, 2016 at 07:17:14PM CEST, dsa@cumulusnetworks.com wrote:
>On 7/21/16 4:03 AM, Jiri Pirko wrote:
>>From: Nogah Frankel <nogahf@mellanox.com>
>>
>>Add resources query implementation. If exists, query the HW for its
>>builtin resources instead of having them as consts in the code.
>>
>>Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>>Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>>Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>any plans to allow userspace to query h/w resources -- e.g, via devlink?

In future, yes.

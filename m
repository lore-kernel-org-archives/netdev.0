From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 1/9] mlxsw: pci: Add resources query
 implementation.
Date: Fri, 22 Jul 2016 11:17:14 -0600
Message-ID: <d8da3a59-34a8-e287-103e-c236f66aad3d@cumulusnetworks.com>
References: <1469095397-3837-1-git-send-email-jiri@resnulli.us>
 <1469095397-3837-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34439 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbcGVRRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 13:17:21 -0400
Received: by mail-pf0-f180.google.com with SMTP id p64so43220107pfb.1
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 10:17:21 -0700 (PDT)
In-Reply-To: <1469095397-3837-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/16 4:03 AM, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
>
> Add resources query implementation. If exists, query the HW for its
> builtin resources instead of having them as consts in the code.
>
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

any plans to allow userspace to query h/w resources -- e.g, via devlink?

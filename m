From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/12] mlxsw: Preparations for restructuring
Date: Wed, 17 May 2017 14:07:17 -0400 (EDT)
Message-ID: <20170517.140717.364744953151668421.davem@davemloft.net>
References: <20170516173835.2978-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932073AbdEQSHV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 14:07:21 -0400
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 16 May 2017 19:38:23 +0200

> This patchset doesn't introduce any functional changes and merely meant
> to make the code base more receptive for upcoming restructuring.
> 
> The first six patches mainly shuffle code in order to reduce the scope of
> structs that shouldn't be defined in the main driver header. Most of them
> will be later expanded, so it makes sense to correctly place them now.
> 
> The last patches mostly simplify bridge-related functions, so that they
> could be more easily modified later on.

Looks good, series applied, thanks.

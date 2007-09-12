From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/16] net: Factor out __dev_alloc_name from
 dev_alloc_name
Date: Wed, 12 Sep 2007 04:49:19 -0700 (PDT)
Message-ID: <20070912.044919.74734903.davem@davemloft.net>
References: <m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com>
	<m17in0vo0d.fsf_-_@ebiederm.dsl.xmission.com>
	<m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54340
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764540AbXILLtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:49:22 -0400
In-Reply-To: <m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:36:56 -0600

> 
> When forcibly changing the network namespace of a device
> I need something that can generate a name for the device
> in the new namespace without overwriting the old name.
> 
> __dev_alloc_name provides me that functionality.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.

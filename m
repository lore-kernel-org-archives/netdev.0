From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/16] appletalk: In notifier handlers convert the void
 pointer to a netdevice
Date: Wed, 12 Sep 2007 02:27:56 -0700 (PDT)
Message-ID: <20070912.022756.59666467.davem@davemloft.net>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:50875
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764143AbXILJ2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 05:28:00 -0400
In-Reply-To: <m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:09:36 -0600

> 
> This slightly improves code safetly and clarity.
> 
> Later network namespace patches touch this code so this is a
> preliminary cleanup.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24

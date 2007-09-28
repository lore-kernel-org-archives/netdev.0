From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bring comments in loopback.c uptodate.
Date: Thu, 27 Sep 2007 17:09:47 -0700 (PDT)
Message-ID: <20070927.170947.88719290.davem@davemloft.net>
References: <m1lkarhgw6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40486
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759541AbXI1AJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 20:09:47 -0400
In-Reply-To: <m1lkarhgw6.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Sep 2007 16:39:53 -0600

> 
> A hint as to why it is safe to use per cpu variables,
> and note that we actually can have multiple instances
> of the loopback device now.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.

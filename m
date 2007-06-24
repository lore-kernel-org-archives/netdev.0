From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 22:48:53 -0700 (PDT)
Message-ID: <20070623.224853.12137896.davem@davemloft.net>
References: <20070623.135737.22037347.davem@davemloft.net>
	<467D9B8F.2050403@garzik.org>
	<m1ejk28eku.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, kaber@trash.net, netdev@vger.kernel.org,
	hadi@cyberus.ca, shemminger@linux-foundation.org,
	greearb@candelatech.com, yoshfuji@linux-ipv6.org,
	containers@lists.osdl.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37801
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753133AbXFXFsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 01:48:35 -0400
In-Reply-To: <m1ejk28eku.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 23 Jun 2007 16:56:49 -0600

> If the only use was strong isolation which Dave complains about I would
> concur that the namespace approach is inappropriate.  However there are
> a lot other uses.

By your very admission the only appropriate use case is when users
are not "hostile" and can be trusted to some extent.

And that by definition makes it not appropriate for a general purpose
operating system like Linux.

Containers are I believe a step backwards, and we're better than that.

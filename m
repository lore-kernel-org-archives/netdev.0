From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 16:53:18 -0700
Message-ID: <20070917165318.36a1f1a7.akpm@linux-foundation.org>
References: <20070916.202258.03371690.davem@davemloft.net>
	<20070917.141826.70218261.davem@davemloft.net>
	<20070917144037.100b3fc1.akpm@linux-foundation.org>
	<20070917.163929.107941522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, jgarzik@pobox.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34475 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756119AbXIQXyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 19:54:10 -0400
In-Reply-To: <20070917.163929.107941522.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Sep 2007 16:39:29 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 17 Sep 2007 14:40:37 -0700
> 
> > These two:
> > 
> > git://porch.greyhouse.net/gospo/tehuti-2.6.git
> > ipg-add-ip1000a-driver-to-kernel-tree.patch
> > 
> > plus boatloads of stuff in wireless.
> 
> Andrew, can you send these two to me under seperate cover?  I'll
> integrate them once I have them in my inbox.

The Tehuti driver you should probably pull from the above git tree.

Andy sent me a fix-it-for-net-2.6.24 patch which I'll send.  It applies
on top of the git tree.

ipg-add-ip1000a-driver-to-kernel-tree.patch got broken by git-2.6.24 and I
just disabled it in Kconfig.  I'll send it anyway but someone will need to
repair it.  For some reason this driver doesn't have a changelog.


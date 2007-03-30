From: David Miller <davem@davemloft.net>
Subject: Re: tcp crash in net-2.6 tree
Date: Fri, 30 Mar 2007 15:12:28 -0700 (PDT)
Message-ID: <20070330.151228.93642549.davem@davemloft.net>
References: <Pine.LNX.4.64.0703301618510.23854@kivilampi-30.cs.helsinki.fi>
	<20070330.144347.68157619.davem@davemloft.net>
	<20070330150603.edeb2023.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932458AbXC3WMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 18:12:45 -0400
In-Reply-To: <20070330150603.edeb2023.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 30 Mar 2007 15:06:03 -0700

> > Andrew please give this debugging patch a spin,
> 
> OK, will take a look at that this evening, hopefully.

BTW, Thomas Graf can also reproduce this and he is about
to post a log message from my patch.

> distccd seems to be rather good at triggering networking problems - I think
> that's the third one I've seen in the past few years.

Agreed, I remember the other hairy problems distcc could trigger.

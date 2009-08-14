From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Fri, 14 Aug 2009 13:12:18 -0700 (PDT)
Message-ID: <20090814.131218.139318801.davem@davemloft.net>
References: <1250230925.6641.92.camel@fnki-nb00130>
	<20090814.001519.40499255.davem@davemloft.net>
	<1250237739.16632.12.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, chuck.lever@oracle.com, brian.haley@hp.com,
	netdev@vger.kernel.org
To: jens@mcbone.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756149AbZHNUMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 16:12:08 -0400
In-Reply-To: <1250237739.16632.12.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <jens@mcbone.net>
Date: Fri, 14 Aug 2009 10:15:39 +0200

> I wasn't sure whether "currently user visible stuff" would mean "user
> space interfaces" like sys/proc-fs, which the first quoted post asked
> about, or also kernel messages.

I'd say that kernel log messages are OK to tinker with, whereas procfs
and sysfs file contents are not.

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] socket.7: add description for SO_BUSY_POLL
Date: Wed, 10 Jul 2013 12:55:19 +0000
Message-ID: <u0lr4f6h8w8.fsf@orc05.imf.au.dk>
References: <20130710121745.13118.86907.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43700 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753834Ab3GJNUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 09:20:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UwuJP-0006sH-18
	for netdev@vger.kernel.org; Wed, 10 Jul 2013 15:20:03 +0200
Received: from orc05.imf.au.dk ([130.225.20.35])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 15:20:03 +0200
Received: from linux by orc05.imf.au.dk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 15:20:03 +0200
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliezer Tamir <eliezer.tamir@linux.intel.com> writes:

> +While busy polling my improve latency of some application, care must be
> +taken when using it since this will increase both CPU utilization power usage.

s/my/may/; missing 'and' before 'power usage'. [And should
'application' be plural?]

Rasmus

From: Joe Perches <joe@perches.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Sat, 31 Oct 2009 22:23:59 -0700
Message-ID: <1257053039.1917.147.camel@Joe-Laptop.home>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1165 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750817AbZKAFXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2009 01:23:55 -0400
In-Reply-To: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are an awful lot of non linux standard
uses in this code set.

Perhaps staging would be a good place to start?


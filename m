From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Sun, 1 Nov 2009 11:25:53 -0800
Message-ID: <20091101112553.1dc0e3a9@nehalam>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
	<1257053039.1917.147.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rasesh Mody <rmody@brocade.com>, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34275 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752917AbZKAT0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2009 14:26:21 -0500
In-Reply-To: <1257053039.1917.147.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Oct 2009 22:23:59 -0700
Joe Perches <joe@perches.com> wrote:

> There are an awful lot of non linux standard
> uses in this code set.
> 
> Perhaps staging would be a good place to start?
> 

Yup, it looks like a Windows driver port

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [patch] llc: cleanup: remove dead code from llc_init()
Date: Wed, 24 Mar 2010 10:54:18 -0300
Message-ID: <20100324135418.GD23594@ghostprotocols.net>
References: <20100324115510.GC21571@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:52406 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755688Ab0CXNyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 09:54:23 -0400
Content-Disposition: inline
In-Reply-To: <20100324115510.GC21571@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Mar 24, 2010 at 02:55:10PM +0300, Dan Carpenter escreveu:
> We don't need "dev" any more after:
> 	a5a04819c5740cb1aa217af2cc8f5ef26f33d744
> 	[LLC]: station source mac address
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Old leftovers, well spotted, Dave, please apply.


Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

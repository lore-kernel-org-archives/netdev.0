From: David Miller <davem@davemloft.net>
Subject: Re: [patch] llc: cleanup: remove dead code from llc_init()
Date: Wed, 24 Mar 2010 13:34:33 -0700 (PDT)
Message-ID: <20100324.133433.20926021.davem@davemloft.net>
References: <20100324115510.GC21571@bicker>
	<20100324135418.GD23594@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, opurdila@ixiacom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42263
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932573Ab0CXUeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:34:11 -0400
In-Reply-To: <20100324135418.GD23594@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Mar 2010 10:54:18 -0300

> Em Wed, Mar 24, 2010 at 02:55:10PM +0300, Dan Carpenter escreveu:
>> We don't need "dev" any more after:
>> 	a5a04819c5740cb1aa217af2cc8f5ef26f33d744
>> 	[LLC]: station source mac address
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Old leftovers, well spotted, Dave, please apply.
> 
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, thanks.

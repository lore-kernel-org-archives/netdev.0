From: David Miller <davem@davemloft.net>
Subject: Re: resurrecting tcphealth
Date: Sat, 14 Jul 2012 12:29:13 -0700 (PDT)
Message-ID: <20120714.122913.1391783610681090477.davem@davemloft.net>
References: <cc6495b92f1df180c1ad43057ceb0b98.squirrel@webmail.univie.ac.at>
	<1342254423.3265.9028.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a9702387@unet.univie.ac.at, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab2GNT3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 15:29:14 -0400
In-Reply-To: <1342254423.3265.9028.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't we report all of this shit in tcp_info already?

I really hate such cruddy patches like this.

From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Thu, 10 May 2007 13:35:22 -0700 (PDT)
Message-ID: <20070510.133522.99205764.davem@davemloft.net>
References: <20070509023131.70e2cc45.billfink@mindspring.com>
	<20070510113215.f5ff2d34.billfink@mindspring.com>
	<2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, sangtae.ha@gmail.com,
	netdev@vger.kernel.org
To: rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39118
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755592AbXEJUfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:35:19 -0400
In-Reply-To: <2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: rhee@ncsu.edu
Date: Thu, 10 May 2007 14:39:25 -0400 (EDT)

> 
> Bill,
> Could you test with the lastest version of CUBIC? this is not the latest
> version of it you tested.

Rhee-sangsang-nim, it might be a lot easier for people if you provide
a patch against the current tree for users to test instead of
constantly pointing them to your web site.

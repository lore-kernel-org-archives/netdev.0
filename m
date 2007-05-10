From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Thu, 10 May 2007 13:45:47 -0700
Message-ID: <20070510134547.7ec30308@freepuppy>
References: <20070509023131.70e2cc45.billfink@mindspring.com>
	<20070510113215.f5ff2d34.billfink@mindspring.com>
	<2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu>
	<20070510.133522.99205764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rhee@ncsu.edu, billfink@mindspring.com, sangtae.ha@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40174 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758769AbXEJUq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 16:46:28 -0400
In-Reply-To: <20070510.133522.99205764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 May 2007 13:35:22 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: rhee@ncsu.edu
> Date: Thu, 10 May 2007 14:39:25 -0400 (EDT)
> 
> > 
> > Bill,
> > Could you test with the lastest version of CUBIC? this is not the latest
> > version of it you tested.
> 
> Rhee-sangsang-nim, it might be a lot easier for people if you provide
> a patch against the current tree for users to test instead of
> constantly pointing them to your web site.
> -

The 2.6.22 version should have the latest version, that I know of.
There was small patch from 2.6.21 that went in.

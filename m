From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Fri, 23 Jun 2006 19:45:50 -0400
Message-ID: <449C7D2E.8000101@hp.com>
References: <20060621200031.589235000@flek.zko.hp.com>  <20060622.021223.125894633.davem@davemloft.net>  <1151088481.2669.25.camel@localhost.localdomain>  <20060623.131512.21593290.davem@davemloft.net> <1151094857.2669.51.camel@localhost.localdomain> <Pine.LNX.4.64.0606231906380.6209@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ted <txtoth@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:59625 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1752175AbWFWXpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 19:45:52 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606231906380.6209@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> 
> Support for interoperability with legacy CIPSO systems is something that I 
> think would be nice to have, if it can be done in a way which doesn't 
> impact deeply on core kernel code, and plays nicely with native Linux 
> infrastructure.
> 

I'm not sure if you have had a chance to look at the new patch set yet
but I know you have seen earlier versions and are at least familiar with
the approach I am taking ... in your opinion is the NetLabel patch
acceptable in its approach?

-- 
paul moore
linux security @ hp

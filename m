From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] skge: fix swapped kcalloc() arguments
Date: Fri, 18 Aug 2006 15:33:18 -0700
Message-ID: <20060818153318.7c7a9bb9@localhost.localdomain>
References: <200608182354.52537.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58589 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751540AbWHRWdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 18:33:35 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608182354.52537.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Aug 2006 23:54:52 +0200
Michael Buesch <mb@bu3sch.de> wrote:

> Hey Stephen,
> 
> Please push the following fix upstream.
> 

ok, but it can't make much difference, unless someone did something
like try to set ring->count to zero.

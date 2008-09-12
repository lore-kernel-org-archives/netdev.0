From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2.6.28 3/4] myri10ge: Add Toeplitz-hashing related
	routines
Date: Fri, 12 Sep 2008 20:54:35 +0100
Message-ID: <1221249275.3244.74.camel@achroite>
References: <48CAAAEF.1060205@myri.com>  <48CAAB93.2070703@myri.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:35074 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753762AbYILTyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 15:54:41 -0400
In-Reply-To: <48CAAB93.2070703@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-09-12 at 19:49 +0200, Brice Goglin wrote:
> myri10ge uses a Toeplitz hashing. Add the corresponding select_queue()
> method without using it yet.
[...]

Since Microsoft has pushed everyone to implement the Toeplitz hash, this
probably ought to go in the networking core and be exported to drivers.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


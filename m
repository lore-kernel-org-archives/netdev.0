From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: network interface *name* alias support?
Date: Fri, 23 May 2008 15:11:33 -0400
Message-ID: <1211569893.11907.39.camel@perihelion>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>
	 <4836FB73.2010709@intel.com>  <4837026A.6000702@hp.com>
	 <1211569604.11907.37.camel@perihelion>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jan Engelhardt <jengelh@medozas.de>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:37978 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbYEWTLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 15:11:39 -0400
In-Reply-To: <1211569604.11907.37.camel@perihelion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-05-23 at 15:06 -0400, Jon Masters wrote:

> My intention is to also allow for:
> 
> ifcfg-slot_<whatever>
> 
> Where the configuration is based entirely upon what vendor <XYZ> says is
> the first, second, or third card. Then, those who want to use the older
> names can continue to do so, but those who prefer to base their
> configuration upon the order the vendor states, can do so.

I'm aware there are other ways to achieve this than having udev assign
an alias on boot, but I think the alias approach is particularly clean.

Jon.



From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [BUG] stacktrace from skb_checksum_help() and skb_gso_segment()
Date: Wed, 26 Jul 2006 10:44:19 +0400
Message-ID: <20060726064419.GB32190@2ka.mipt.ru>
References: <200607260841.54017.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:7877 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030422AbWGZGoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 02:44:44 -0400
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Content-Disposition: inline
In-Reply-To: <200607260841.54017.eike-kernel@sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 08:41:48AM +0200, Rolf Eike Beer (eike-kernel@sf-tec.de) wrote:
> linux-2.6 git tree from yesterday.
> 
> Before this the sky2 network driver was working. After a pseudo hotplug of the 
> device it was working again (at least if you receive this mail *g*).
> 
> What next?

It is not a bug, but remind to update NAT helper function.
It has nothing with device drivers and is only printed once.

> Eike

-- 
	Evgeniy Polyakov

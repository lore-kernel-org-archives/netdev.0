From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFC/Progress update: e1000e pci-express -only e1000 driver
Date: Sat, 28 Jul 2007 14:07:55 -0400
Message-ID: <46AB85FB.10102@pobox.com>
References: <46AA5FB8.9090600@intel.com> <p73sl78r5yu.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36702 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465AbXG1SIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jul 2007 14:08:00 -0400
In-Reply-To: <p73sl78r5yu.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> "Kok, Auke" <auke-jan.h.kok@intel.com> writes:
> 
>> * Removed all multi-queue code
> 
> Why? With David's new multi NAPI work it will finally make sense, won't it?

It will come back, most definitely.

Not speaking for Auke, but I'm pretty sure this falls under the category 
of "start small and simple, get it into the tree rapidly."

	Jeff




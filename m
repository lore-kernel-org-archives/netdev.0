From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC/Progress update: e1000e pci-express -only e1000 driver
Date: 28 Jul 2007 15:52:09 +0200
Message-ID: <p73sl78r5yu.fsf@bingen.suse.de>
References: <46AA5FB8.9090600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:56440 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbXG1M52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jul 2007 08:57:28 -0400
In-Reply-To: <46AA5FB8.9090600@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Kok, Auke" <auke-jan.h.kok@intel.com> writes:

> * Removed all multi-queue code

Why? With David's new multi NAPI work it will finally make sense, won't it?

-Andi (who would finally like to see a driver which is able to process
incoming packets and TX completion interrupts on multiple CPUs) 


From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Tue, 23 Oct 2007 22:38:04 +0100
Message-ID: <20071023223804.2ee9755f@the-village.bc.nu>
References: <11931515302013-git-send-email-ajax@redhat.com>
	<471E1ECD.80002@intel.com>
	<1193156487.26974.39.camel@localhost.localdomain>
	<471E2AD0.1000500@intel.com>
	<471E5C21.8030908@garzik.org>
	<20071023212026.GF7793@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Adam Jackson <ajax@redhat.com>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:59128 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751862AbXJWVf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 17:35:27 -0400
In-Reply-To: <20071023212026.GF7793@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> People aren't going to report this as a bug. They aren't going to try out patches,
> they're going to do what I did and stick another network card in the box and
> go on with life.
> 
> Our users deserve better than this.

Agreed. By all means warn people, or give them a 1-800 Intel number to
phone, but they should be able to continue as well.

Alan

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [parisc-linux] [git patches] tulip fixes from parisc-linux
Date: Sun, 30 Jul 2006 18:56:15 -0400
Message-ID: <44CD390F.5000305@garzik.org>
References: <20060729225459.GA4835@athena.road.mcmartin.ca> <20060730004339.GC11975@colo.lackof.org> <20060730165607.GB4835@athena.road.mcmartin.ca> <20060730113532.4db2fcb5.akpm@osdl.org> <20060730185456.GA17066@tachyon.int.mcmartin.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, grundler@parisc-linux.org,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	parisc-linux@lists.parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:30935 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964780AbWG3W4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 18:56:19 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <20060730185456.GA17066@tachyon.int.mcmartin.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle McMartin wrote:
> parisc-linux
> merged Francois' tulip workqueue patch some time ago, and have been
> running with it since without issue. This defers the tulip_select_media
> work to process context, and so should be less of an issue.

Good to hear.  That's definitely my preference for future direction...

	Jeff



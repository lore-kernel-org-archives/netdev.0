From: Jeff Garzik <jeff@garzik.org>
Subject: Re: RFR: New e1000 driver (e1000new), was: Re: e1000: backport ich9
 support from 7.5.5 ?
Date: Sun, 08 Jul 2007 14:20:56 -0400
Message-ID: <46912B08.4080306@garzik.org>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org> <468594B7.6070309@intel.com> <ada8xa29kx9.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41991 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754671AbXGHSVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2007 14:21:00 -0400
In-Reply-To: <ada8xa29kx9.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> one possibility would be to merge e1000new with support only for chips
> not supported by e1000, and semi-freeze e1000 (fixes only, new device
> support goes into e1000new).

indeed.

	Jeff



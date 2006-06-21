From: Stefan Rompf <stefan@loplof.de>
Subject: Re: Suspending 802.11 drivers
Date: Wed, 21 Jun 2006 11:42:12 +0200
Message-ID: <200606211142.12790.stefan@loplof.de>
References: <200606152158.10079.mb@bu3sch.de> <200606162036.26518.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from natlemon.rzone.de ([81.169.145.170]:27373 "EHLO
	natlemon.rzone.de") by vger.kernel.org with ESMTP id S932497AbWFUJks
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 05:40:48 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606162036.26518.stefan@loplof.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag 16 Juni 2006 20:36 schrieb Stefan Rompf:

> (But that's an interesting point. Will sniff whether ipw2200 hardware sends
> a final packet on suspend.)

neither on suspend to RAM nor on suspend to disk a disassociation is sent by 
ipw2200 - for the AP, the client just vanishes.

Stefan

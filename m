From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 15:42:06 +0200
Message-ID: <486E28AE.1020801@firstfloor.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>	 <20080703173040.GB30506@mit.edu>	 <1215111362.10393.651.camel@pmac.infradead.org>	 <20080703.162120.206258339.davem@davemloft.net>	 <486D6DDB.4010205@infradead.org>  <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tytso@mit.edu, jeff@garzik.org,
	hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58860 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757999AbYGDNmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 09:42:13 -0400
In-Reply-To: <1215177044.10393.743.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> No, not even in the initramfs. It's built _right_ into the static kernel
> image, and request_firmware() finds it there without even having to call
> out to userspace at all.

Great. Thanks.

-Andi



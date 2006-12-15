From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Rt2400-devel] [PATCH] rt2x00: Fix PKT_PROBE_RESP breakage
Date: Fri, 15 Dec 2006 20:54:00 +0100
Message-ID: <200612152054.00447.mb@bu3sch.de>
References: <200612152039.20635.mb@bu3sch.de> <200612152050.30249.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rt2400-devel@lists.sourceforge.net, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, "Linville, John" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54854
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbWLOTyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:54:24 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200612152050.30249.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 15 December 2006 20:50, Ivo van Doorn wrote:
> Hi,
> 
> On Friday 15 December 2006 20:39, Michael Buesch wrote:
> > Fix breakage from removal of PKT_PROBE_RESP.
> 
> Jiri had already send a patch to the netdev list to cover this breakage.
> ([PATCH 1/2] rt2x00: fix breakage after pkt_type field was removed)
> And I personally favour the patch from Jiri.

Ah, well. I don't care. I had to fix this to get my other patch done. ;)

-- 
Greetings Michael.

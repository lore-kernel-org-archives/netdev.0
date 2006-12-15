From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [Rt2400-devel] [PATCH] rt2x00: Fix PKT_PROBE_RESP breakage
Date: Fri, 15 Dec 2006 20:50:29 +0100
Message-ID: <200612152050.30249.IvDoorn@gmail.com>
References: <200612152039.20635.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, "Linville, John" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:46291 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbWLOTum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:50:42 -0500
Received: by ug-out-1314.google.com with SMTP id 44so899189uga
        for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 11:50:42 -0800 (PST)
To: rt2400-devel@lists.sourceforge.net
In-Reply-To: <200612152039.20635.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Friday 15 December 2006 20:39, Michael Buesch wrote:
> Fix breakage from removal of PKT_PROBE_RESP.

Jiri had already send a patch to the netdev list to cover this breakage.
([PATCH 1/2] rt2x00: fix breakage after pkt_type field was removed)
And I personally favour the patch from Jiri.

Ivo

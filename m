From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: [PATCH 2/2] bnx2: move gzip unpacker to zlib
Date: Fri, 21 Sep 2007 12:03:35 +0100
Message-ID: <200709211203.35956.vda.linux@googlemail.com>
References: <200709211201.24475.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:24163 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbXIULDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 07:03:42 -0400
Received: by ug-out-1314.google.com with SMTP id z38so501148ugc
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 04:03:41 -0700 (PDT)
In-Reply-To: <200709211201.24475.vda.linux@googlemail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 September 2007 12:01, Denys Vlasenko wrote:
> I will move this code
> out of the driver and into zlib in follow-on patch.

No, I won't. I accidentally attached both patches to first email,
you can find it there. Sorry.
--
vda

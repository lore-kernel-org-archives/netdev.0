From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Netxen packet loss with VLANs and LRO (was: [PATCH] netxen:
	fix LRO disable warning)
Date: Tue, 5 Apr 2011 17:18:54 +0200
Message-ID: <20110405151854.GA32759@torres.zugschlus.de>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com> <20110403190555.GA16196@torres.zugschlus.de> <99737F4847ED0A48AECC9F4A1974A4B80FD10E8E3C@MNEXMB2.qlogic.org> <20110405124158.GA28382@torres.zugschlus.de> <99737F4847ED0A48AECC9F4A1974A4B80FD1383943@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:44202 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273Ab1DEPSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 11:18:55 -0400
Content-Disposition: inline
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD1383943@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 08:15:16AM -0500, Amit Salecha wrote:
> This will fix LRO configuration problem. Do you see packet loss with
> LRO disable ?

No, with LRO disabled things seem to be fine. LRO gets enabled by
default though.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190

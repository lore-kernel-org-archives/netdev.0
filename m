From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it,
 anyways? [compare with e.g. NBD + MD raid])
Date: Mon, 13 Aug 2007 11:02:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708131102310.28963@fbirervta.pbzchgretzou.qr>
References: <200708121335.17267.a1426z@gawab.com>
 <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr>
 <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm>
 <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr>
 <20070812174549.GA2915@teal.hq.k1024.org> <46BFB6BB.80406@steeleye.com>
 <Pine.LNX.4.64.0708122016100.22470@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Clements <paul.clements@steeleye.com>,
	Al Boldi <a1426z@gawab.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-raid@vger.kernel.org
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:58657 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S971006AbXHMJCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 05:02:55 -0400
In-Reply-To: <Pine.LNX.4.64.0708122016100.22470@asgard.lang.hm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 12 2007 20:21, david@lang.hm wrote:
>
> per the message below MD (or DM) would need to be modified to work
> reasonably well with one of the disk components being over an
> unreliable link (like a network link)

Does not dm-multipath do something like that?

> are the MD/DM maintainers interested in extending their code in this direction?
> or would they prefer to keep it simpler by being able to continue to assume
> that the raid components are connected over a highly reliable connection?

	Jan
-- 

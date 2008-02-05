From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 21:25:28 +0000
Message-ID: <20080205212528.5f1e5a32@core>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
	<20080205155558.GA23145@one.firstfloor.org>
	<Pine.LNX.4.64.0802052056120.16441@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:60235 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756377AbYBEVbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 16:31:15 -0500
In-Reply-To: <Pine.LNX.4.64.0802052056120.16441@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >So I don't think it makes much sense to add more code to it, sorry.
> 
> Distributions should then probably deactivate it by default.
> SUSE 10.3 for example still has it enabled on default installs.

Even though I work the loyal opposition to SuSE I'd say SuSE 10.3 is
correct in having it enabled in the build.

Alan

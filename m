From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: missing icmp redirects
Date: Tue, 8 Apr 2014 17:34:35 +0200
Message-ID: <DUB123-W19EE656C7ECB42B9D05319ED6B0@phx.gbl>
References: <5343FE4D.40805@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Per Jessen <per@computer.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s19.dub0.hotmail.com ([157.55.2.94]:62299 "EHLO
	dub0-omc4-s19.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757285AbaDHPeh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 11:34:37 -0400
In-Reply-To: <5343FE4D.40805@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> See complete description here:
>
> https://bugzilla.kernel.org/show_bug.cgi?id=72561
>
> Summary - some ICMP redirects seem to be missing.
>
> Alan suggests I gather some traces, but I'm am unsure of what to trace.
> Suggestions please?

Reproduce the actual issue and post a simplified testcase, without
transparent proxying, etc.

 		 	   		  
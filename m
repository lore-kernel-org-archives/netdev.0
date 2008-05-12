From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 22:25:15 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805122220520.14152@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
 <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com>
 <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi> <4828304F.4040908@damtek.com>
 <Pine.LNX.4.64.0805121503280.1888@wrl-59.cs.helsinki.fi> <482849C9.30905@damtek.com>
 <Pine.LNX.4.64.0805121656440.1888@wrl-59.cs.helsinki.fi> <48288EFE.4020708@damtek.com>
 <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi> <4828981E.1000104@damtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "Damon L. Chesser" <damon@damtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42258 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbYELTZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 15:25:19 -0400
In-Reply-To: <4828981E.1000104@damtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2008, Damon L. Chesser wrote:

> One more question from me, what release will we see these updates in, 2.6.26?

Yes, 2.6.26 will have it. They will also be included to stable-2.6.25, 
though I currently don't know yet what the minormost number will then be, 
likely .4 or .5 but like I said I don't know yet :-). I don't know if 
2.6.24.y will get some releases, if it does, it might come there as well. 
...And about when distros acquire it to their kernel, I don't really have 
any idea :-).

-- 
 i.

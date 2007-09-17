From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Distributed storage. Security attributes and ducumentation update.
Date: Mon, 17 Sep 2007 18:22:30 +0000
Message-ID: <20070917182229.GA5966@ucw.cz>
References: <20070831160611.GA21660@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:3574 "EHLO spitz.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754025AbXIVGpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 02:45:13 -0400
Content-Disposition: inline
In-Reply-To: <20070831160611.GA21660@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> I'm pleased to announce third release of the distributed storage
> subsystem, which allows to form a storage on top of remote and local
> nodes, which in turn can be exported to another storage as a node to
> form tree-like storages.

How is this different from raid0/1 over nbd? Or raid0/1 over
ata-over-ethernet?

> +|---------------- DST storate -------------------|

storage?


							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

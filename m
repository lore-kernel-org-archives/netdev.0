From: Kees Cook <kees.cook@canonical.com>
Subject: shutdown(2) does not fully shut down socket any more
Date: Fri, 8 Apr 2011 15:10:46 -0700
Message-ID: <20110408221046.GW4050@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:43454 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040Ab1DHWKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:10:47 -0400
Received: from www.outflux.net (serenity-end.outflux.net [10.2.0.2])
	by vinyl.outflux.net (8.14.3/8.14.3/Debian-9.1ubuntu1) with ESMTP id p38MAklP014534
	for <netdev@vger.kernel.org>; Fri, 8 Apr 2011 15:10:46 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all,

I've got a weird regression visible here:
https://bugzilla.kernel.org/show_bug.cgi?id=32832

Can other people reproduce this, and if so, what's going on? Seems like a
kernel bug unless I'm misunderstanding something.

Thanks!

-Kees

-- 
Kees Cook
Ubuntu Security Team

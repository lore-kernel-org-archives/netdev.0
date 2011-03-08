From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] Phonet: fix NULL-deref in
 a8059512b120362b15424f152b2548fe8b11bd0c
Date: Tue, 08 Mar 2011 13:09:26 -0800 (PST)
Message-ID: <20110308.130926.246531377.davem@davemloft.net>
References: <1299592626-18510-1-git-send-email-remi.denis-courmont@nokia.com>
	<20110308.112923.39177383.davem@davemloft.net>
	<201103082259.41844.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752046Ab1CHVIt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 16:08:49 -0500
In-Reply-To: <201103082259.41844.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Tue, 8 Mar 2011 22:59:41 +0200

> I just wish you'd been as strict back then.

The only thing worse that putting crappy code into the tree is having
patches rot in patchwork because the maintainer isn't responsive at
reviewing things.

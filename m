From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH tcp-2.6 0/2]: SACK block validation
Date: Mon, 18 Jun 2007 23:18:47 -0700 (PDT)
Message-ID: <20070618.231847.88493324.davem@davemloft.net>
References: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45191
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751869AbXFSGS3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 02:18:29 -0400
In-Reply-To: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 19 Jun 2007 01:25:56 +0300

> Do you have some plans regarding tcp-2.6?

It is sort-of stuck in the mud until some real performance analysis of
the RB-Tree stuff can be done.

I'm currently knee-deep in working on support for some virtualization
disk and network drivers on sparc64, but once I clear away with that I
hope to get to some performance work with the RB-Tree stuff.

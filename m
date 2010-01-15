From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] macvlan: add GRO bit to features mask
Date: Fri, 15 Jan 2010 11:08:06 +0100
Message-ID: <4B503E86.8010603@trash.net>
References: <20100114215058.4958.87746.stgit@mimic.site> <20100114215310.4958.46657.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52782 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279Ab0AOKIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 05:08:09 -0500
In-Reply-To: <20100114215310.4958.46657.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Mullaney wrote:
> Allow macvlan devices to support GRO.

Acked-by: Patrick McHardy <kaber@trash.net>

Please send this patch to Dave, this can already go upstream.

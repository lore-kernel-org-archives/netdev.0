From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2.6.27-rc1]: fix NE2000 linkage error
Date: Wed, 30 Jul 2008 15:04:50 +0100
Message-ID: <20080730150450.3bd7c853@lxorguk.ukuu.org.uk>
References: <200807301144.m6UBitOG022822@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:49298 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752741AbYG3OWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 10:22:04 -0400
In-Reply-To: <200807301144.m6UBitOG022822@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 13:44:55 +0200 (MEST)
Mikael Pettersson <mikpe@it.uu.se> wrote:

> Trying to build with CONFIG_NE2000=m fails with:

Yes I've sent patches to fix this to Jeff a couple of times.

Alan

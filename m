From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-2.6 PATCH 3/10] Neterion: New driver: Kconfig and Makefile
Date: Sun, 15 Mar 2009 19:09:39 +0000
Message-ID: <1237144179.4209.31.camel@hashbaz.i.decadent.org.uk>
References: <1237018842.4966.418.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50187 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754703AbZCOTJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 15:09:43 -0400
In-Reply-To: <1237018842.4966.418.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-14 at 00:20 -0800, Ramkrishna Vepa wrote:
> - Kconfig and Makefile related changes for vxge driver.
[...]

These should really come last in the series so they don't refer to
nonexistent files.  This may not matter for a new driver as Dave can
squash them together into one patch.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

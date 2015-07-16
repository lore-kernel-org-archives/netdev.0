From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 2/8] cdc-ncm: use common CDC parser
Date: Fri, 17 Jul 2015 00:09:15 +0200
Message-ID: <1437084555.2259.0.camel@suse.com>
References: <1437074680-3515-1-git-send-email-oneukum@suse.com>
	 <1437074680-3515-2-git-send-email-oneukum@suse.com>
	 <B0A92094-0F80-4B93-9CC0-274C75E6B095@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46281 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbbGPWKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 18:10:22 -0400
In-Reply-To: <B0A92094-0F80-4B93-9CC0-274C75E6B095@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-16 at 22:18 +0200, Bj=C3=B8rn Mork wrote:
> I'm on vacation without any usable Internet or other code access, so =
you'll have to excuse me if I'm missing something.  But this seems to l=
eave union_desc uninitialized, doesn't it?

Yes, good catch. I'll make a new version.

	Thanks
		Oliver

From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] libertas: drop maintainership
Date: Mon, 18 Mar 2013 10:23:12 -0700
Message-ID: <1363627392.2074.21.camel@joe-AO722>
References: <1363625321.1597.28.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Daniel Drake <dsd@laptop.org>, Bing Zhao <bzhao@marvell.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60311 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751506Ab3CRRXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 13:23:14 -0400
In-Reply-To: <1363625321.1597.28.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 11:48 -0500, Dan Williams wrote:
> Would be better maintained by somebody who actualy has time for it.
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> -MARVELL LIBERTAS WIRELESS DRIVER
> -M:	Dan Williams <dcbw@redhat.com>
> -L:	libertas-dev@lists.infradead.org
> -S:	Maintained
> -F:	drivers/net/wireless/libertas/

I think it better to mark it as Orphan
and maybe leave the list.

Maybe:

MARVELL LIBERTAS WIRELESS DRIVER
L:	libertas-dev@lists.infradead.org
S:	Orphan
F:	drivers/net/wireless/libertas/

or

MARVELL LIBERTAS WIRELESS DRIVER
S:	Orphan
F:	drivers/net/wireless/libertas/

From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 0/3] [ISDN] Documentation patchset
Date: Wed, 22 Apr 2009 17:40:10 -0700
Message-ID: <20090422174010.1d6a859a.randy.dunlap@oracle.com>
References: <cover.1240410708.git.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, tilman@imap.cc,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org
To: "Karsten Keil" <Karsten-Keil@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:61627 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbZDWAp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 20:45:56 -0400
In-Reply-To: <cover.1240410708.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Apr 2009 16:31:48 +0200 Karsten Keil wrote:

> Add some useful documentation for the ISDN subsystem.
> Orignal patches are from Tilman Schmidt.
> I fixed some whitespace issues and added the URL for the CAPI 2.0 spec.

Looks good.  Thanks.

Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>


> Karsten Keil (1):
>   Add reference to CAPI 2.0 standard
> 
> Tilman Schmidt (2):
>   update Documentation/isdn/00-INDEX
>   Documentation/isdn/INTERFACE.CAPI
> 
>  Documentation/isdn/00-INDEX       |   17 +++-
>  Documentation/isdn/INTERFACE.CAPI |  208 +++++++++++++++++++++++++++++++++++++
>  drivers/isdn/capi/kcapi.c         |  171 ++++++++++++++++++++++++++++++
>  3 files changed, 392 insertions(+), 4 deletions(-)
>  create mode 100644 Documentation/isdn/INTERFACE.CAPI


---
~Randy

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] [RESEND] netlink error magngement + others
Date: Thu, 22 Mar 2007 23:31:40 -0700 (PDT)
Message-ID: <20070322.233140.78735326.davem@davemloft.net>
References: <20070322221804.000124130@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933253AbXCWGbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 02:31:40 -0400
In-Reply-To: <20070322221804.000124130@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 22 Mar 2007 23:18:04 +0100

> I've rediffed all patches and combined the two patchsets into
> one.  Patrick has already queued the NLM_F_REQUEST change for
> nfnetlink.
> 
> [PATCH 0/5] [PATCHSET] Netlink Patches
> Converts westwood and vegas netlink code to use the typesafe
> interface, removes an unused varaible, and move some netlink
> queue management code into the generic layer.
> 
> [PATCH 0/3] [PATCHSET] netlink error management
> This series of patches simplifies the error management and
> signalization of dump starts of netlink_run_queue() message
> handlers. It touches a fair bit of nfnetlink code as the
> error pointer has been passed on to subsystems.

I've applied everything here, that is what works best
for me, thanks.

If I merged something Patrick was going to take care of
I'm sure he can deal with that :-)

From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 9/13] cxgb3 - Update internal memory management
Date: Tue, 14 Aug 2007 17:09:50 -0700
Message-ID: <46C2444E.1080000@chelsio.com>
References: <20070811063015.8166.66861.stgit@speedy5> <46C14189.8010304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:24970 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434AbXHOAJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 20:09:54 -0400
In-Reply-To: <46C14189.8010304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
>
> Divy Le Ray wrote:
> > From: Divy Le Ray <divy@chelsio.com>
> >
> > Set PM1 internal memory to round robin mode
> >
> > Signed-off-by: Divy Le Ray <divy@chelsio.com>
>
> why?
>
For multiport adapters, it balances access to this internal memory.

Divy

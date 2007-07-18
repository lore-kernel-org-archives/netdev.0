From: Patrick McHardy <kaber@trash.net>
Subject: Re: updated tcatm patches for kernel/iproute 2.6.22
Date: Thu, 19 Jul 2007 00:58:44 +0200
Message-ID: <469E9B24.2080002@trash.net>
References: <20070718210638.bs44zz4veowqf2kr@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Mailing List <netdev@vger.kernel.org>
To: Sami Farin <safari-kernel@safari.iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50264 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934035AbXGRW7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:59:21 -0400
In-Reply-To: <20070718210638.bs44zz4veowqf2kr@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sami Farin wrote:
> I had used tcatm patch with 2.6.16 kernel and I was
> happy with it.
> Now I patched Linux kernel 2.6.22 and iproute-2.6.22
> for tcatm.  Seems to work (TM).  Only HTB tested.


Let me repeat again before we get in an endless discussion
again - I will NACK these patches until we have a solution
that works for all qdiscs.


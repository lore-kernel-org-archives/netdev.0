From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] libertas: Don't mark exported symbols as static
Date: Fri, 08 Feb 2008 18:01:02 -0800
Message-ID: <adaejbm28ip.fsf@cisco.com>
References: <adatzkj0z7l.fsf@cisco.com> <20080208162824.461451e1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:12589 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405AbYBICBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 21:01:14 -0500
In-Reply-To: <20080208162824.461451e1@extreme> (Stephen Hemminger's message of "Fri, 8 Feb 2008 16:28:24 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Why not pull the exports? they aren't used anywhere in the existing kernel.

I'm guessing there's some not-(yet-)merged mesh networking stuff that
uses the symbols, but it doesn't matter much to me...

 - R.

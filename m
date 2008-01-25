From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 'upstream' 2008-01-24
Date: Thu, 24 Jan 2008 21:26:27 -0800 (PST)
Message-ID: <20080124.212627.193699738.davem@davemloft.net>
References: <20080124195343.GC3200@tuxdriver.com>
	<20080125035751.GC3411@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755437AbYAYF0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 00:26:16 -0500
In-Reply-To: <20080125035751.GC3411@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 24 Jan 2008 22:57:51 -0500

> On Thu, Jan 24, 2008 at 02:53:43PM -0500, John W. Linville wrote:
> 
> > The cfg80211 API change breaks ath5k, so I have listed it as "depends
> > on BROKEN".  I am assured that the ath5k team has agreed to fix
> > this ASAP.  Meanwhile we wanted to have it in place so that we can
> > start shaking-out problems with other drivers.
> 
> Looks like this might have broken more than I expected, and there
> may be some refactoring of the wireless rndis bits too.  So, let's
> hold off on this request.  I'll post a new one in the next day or so.

Ok.

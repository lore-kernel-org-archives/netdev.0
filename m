From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 'upstream' 2008-01-24
Date: Thu, 24 Jan 2008 22:57:51 -0500
Message-ID: <20080125035751.GC3411@tuxdriver.com>
References: <20080124195343.GC3200@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3844 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbYAYEB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 23:01:57 -0500
Content-Disposition: inline
In-Reply-To: <20080124195343.GC3200@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2008 at 02:53:43PM -0500, John W. Linville wrote:

> The cfg80211 API change breaks ath5k, so I have listed it as "depends
> on BROKEN".  I am assured that the ath5k team has agreed to fix
> this ASAP.  Meanwhile we wanted to have it in place so that we can
> start shaking-out problems with other drivers.

Looks like this might have broken more than I expected, and there
may be some refactoring of the wireless rndis bits too.  So, let's
hold off on this request.  I'll post a new one in the next day or so.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com

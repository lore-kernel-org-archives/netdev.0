From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2008-06-13
Date: Fri, 13 Jun 2008 23:21:16 -0400
Message-ID: <20080614032116.GA9171@tuxdriver.com>
References: <20080613214114.GA1077@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2354 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752019AbYFNDck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 23:32:40 -0400
Content-Disposition: inline
In-Reply-To: <20080613214114.GA1077@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 13, 2008 at 05:41:14PM -0400, John W. Linville wrote:

> Another slew of updates intended for 2.6.27...please let me know if
> there are problems!

If you are not in a hurry, you may want to delay this one.  One of
the mac80211 cleanup patches has a one-line endian problem.  Beer and
fatigue suggest that I should look at reworking the tree tomorrow
instead of now.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com

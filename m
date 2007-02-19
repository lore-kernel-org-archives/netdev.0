From: Pavel Roskin <proski@gnu.org>
Subject: Re: Kernel bug in bcm43xx-d80211
Date: Mon, 19 Feb 2007 17:21:34 -0500
Message-ID: <1171923694.2257.21.camel@dv>
References: <358127.50930.qm@web50203.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alex Davis <alex14641@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:43401 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511AbXBSWVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 17:21:37 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1HJGri-0003qj-BT
	for netdev@vger.kernel.org; Mon, 19 Feb 2007 17:20:10 -0500
In-Reply-To: <358127.50930.qm@web50203.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-02-19 at 13:48 -0800, Alex Davis wrote:
> I go the following Oops with the latest wireless-dev git when starting wpa_supplicant:

Wireless topics moved from this list to linux-wireless@vger.kernel.org.
Broadcom drivers are discussed in bcm43xx-dev@lists.berlios.de.
wireless-dev is horribly broken, and the fixes haven't been merged yet.

The current Broadcom driver can be loaded from
http://bu3sch.de/git/wireless-dev.git (please load it on top of
wireless-dev.git to save bandwidth)

It doesn't include the latest breakage from wireless-dev, but it does
include some important fixes.

Although I haven't seen a problem like yours, I strongly suggest that
you try the above repository and post your results to the bcm43xx-dev
list.  Even if the results are more positive :)

-- 
Regards,
Pavel Roskin


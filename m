From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH v2 2/2] mac80211: implement ERP info change
 notifications
Date: Thu, 19 Jul 2007 21:50:16 +0200
Message-ID: <20070719215016.0a768483@griffin.suse.cz>
References: <20070715140822.C9DC07B409F@zog.reactivated.net>
	<20070719191633.GE6603@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, flamingice@sourmilk.net
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:56099 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764841AbXGSTt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 15:49:59 -0400
In-Reply-To: <20070719191633.GE6603@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 15:16:33 -0400, John W. Linville wrote:
> On Sun, Jul 15, 2007 at 03:08:22PM +0100, Daniel Drake wrote:
> > zd1211rw and bcm43xx are interested in being notified when ERP IE conditions
> > change, so that they can reprogram a register which affects how control frames
> > are transmitted.
> > 
> > This patch adds an interface similar to the one that can be found in softmac.
> > 
> > Signed-off-by: Daniel Drake <dsd@gentoo.org>
> 
> Jiri, Michael -- just like the other, this applies to upstream w/
> just some offsets if you ignore the driver bits that aren't upstream.
> Let me know if you are happy w/ this patch.

ACK for both.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs

From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH dscape] d80211: Switch to IEEE80211_ style naming in
 d80211.h
Date: Mon, 24 Jul 2006 15:45:56 +0200
Message-ID: <20060724154556.73b08f51@griffin.suse.cz>
References: <200607240139.36516.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47056 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932166AbWGXNp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 09:45:58 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607240139.36516.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Jul 2006 01:39:30 -0700, Michael Wu wrote:
> Christoph Hellwig made a comment about how the names in ieee80211.h make more 
> sense, and I also agree. This should also make patches for migrating fullmac 
> drivers to d80211 smaller.

Could you split the patch to two patches (one for the d80211 stack and
one for drivers) and add some description to both of them? I will take
care of pushing both patches to John then.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs

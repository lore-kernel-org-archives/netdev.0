From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Wed, 10 Jan 2007 21:13:03 +0100
Message-ID: <20070110211303.137c7e15@griffin.suse.cz>
References: <45996CBA.8020307@web.de>
	<a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
	<20070102162201.GA28457@infradead.org>
	<200701052108.40185.IvDoorn@gmail.com>
	<1168102377.5207.59.camel@johannes.berg>
	<459FD5B5.2050706@web.de>
	<1168102881.5207.63.camel@johannes.berg>
	<a32f33a40701061109o39a55f4fmdd1d252b1f2f2784@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Jan Kiszka" <jan.kiszka@web.de>,
	"Christoph Hellwig" <hch@infradead.org>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36344 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965080AbXAJUNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:13:06 -0500
To: "Ivo Van Doorn" <ivdoorn@gmail.com>
In-Reply-To: <a32f33a40701061109o39a55f4fmdd1d252b1f2f2784@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 6 Jan 2007 20:09:36 +0100, Ivo Van Doorn wrote:
> [...]
> @@ -359,7 +361,7 @@ static int ieee80211_ioctl_remove_sta(struct
> net_device *dev,

The patch is line-wrapped here. Applied, but please try to fix your
mail client settings.

Thanks for the patch,

 Jiri

-- 
Jiri Benc
SUSE Labs

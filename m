From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: ANNOUNCE: DadWifi, a port of MadWifi to d80211
Date: Wed, 18 Oct 2006 17:27:56 +0200
Message-ID: <20061018172756.4733a65c@griffin.suse.cz>
References: <20061018001403.GA22990@devicescape.com>
	<20061018101605.GA1767@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:35970 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161087AbWJRP17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:27:59 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061018101605.GA1767@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2006 11:16:05 +0100, Christoph Hellwig wrote:
> Guys, why do you waste your time on doing stuff that's useless for most
> of us, and that people can't even legally redistribute.

I dislike HAL too. But I don't think this effort is useless. It's a
great base for a future fully open Atheros driver - it's going to use
the d80211 stack anyway, so it can reuse most of the code of this
driver. It also allow us to make sure d80211 is capable of supporting
Atheros chipsets. I appreciate the effort.

AP mode support would be even greater thing - David, do you plan to add
it?

> Please switch to openhal or the openbsd code and we all owe you a lot of
> beer at the next conference :)

And what 802.11 stack would you use with it?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs

From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [d80211 patch 1/1] setting bss freq and phymode using rx_status
Date: Wed, 27 Sep 2006 17:34:41 +0200
Message-ID: <20060927173441.49f5f59f@griffin.suse.cz>
References: <44F356DF.9000000@linux.intel.com>
	<20060921190126.4d884c44@logostar.upir.cz>
	<1158865436.27546.23.camel@localhost.localdomain>
	<4512EC5C.1030807@linux.intel.com>
	<1158870634.5769.21.camel@localhost.localdomain>
	<4512F876.7000203@linux.intel.com>
	<20060922003844.6817f22b@logostar.upir.cz>
	<20060921225514.GA26850@bougret.hpl.hp.com>
	<20060922004235.GA7322@instant802.com>
	<20060922005743.GB27052@bougret.hpl.hp.com>
	<451463D6.4070309@linux.intel.com>
	<20060925181643.1621489a@griffin.suse.cz>
	<45180EB0.1060204@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:33747 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964946AbWI0Pen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:34:43 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <45180EB0.1060204@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Sep 2006 10:15:28 -0700, mabbas wrote:
> actaully we dont even need local->conf.channel. rx_status->channel holds 
> the channel
> we physically received the frame on. channel hold the value from ds. if 
> they are not equal then
> adjust freq. Attached is the modified patch

Applied to my tree. Thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs

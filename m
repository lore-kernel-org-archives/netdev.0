From: Jochen Friedrich <jochen@scram.de>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than	d80211-specific
 qdisc
Date: Thu, 02 Nov 2006 15:41:30 +0100
Message-ID: <454A039A.1050701@scram.de>
References: <20061026050416.GB14199@havoc.gtf.org>	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>	 <20061101112805.246e1b3b@griffin.suse.cz>	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>	 <20061102121657.GA13468@infradead.org> <20061102150550.5c30f704@midnight>	 <20061102141815.GA1795@infradead.org> <1162477954.10786.11.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, Jiri Benc <jbenc@suse.cz>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail0.scram.de ([195.226.127.110]:46091 "EHLO mail0.scram.de")
	by vger.kernel.org with ESMTP id S1750948AbWKBOmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 09:42:08 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162477954.10786.11.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

> On Thu, 2006-11-02 at 14:18 +0000, Christoph Hellwig wrote:
> 
>> This is not about the name that makes sense.  I think using ethX names
>> for wireless devices is utterly stupid, but it's what all current upstream
>> drivers do, and at least for WE compat we'll have to stick to it.
> 
> No, that's not true, zd1201 doesn't [1] :)

Neither does hostap [2] :)

Thanks,
Jochen

[2] http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;h=ed00ebb6e7f4bd255d1a1fe8bf05a6f7a5574d6e;hb=aefba081d7b7dfd1c5752f6e6e709d8b5ab80ab7;f=drivers/net/wireless/hostap/hostap_hw.c#l84



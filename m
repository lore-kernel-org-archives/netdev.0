From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: ipw2100 wireless driver
Date: Wed, 11 Aug 2004 09:30:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811093043.522cc5a0@dell_ss3.pdx.osdl.net>
References: <20040714114135.GA25175@elf.ucw.cz>
	<Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com>
	<20040714115523.GC2269@elf.ucw.cz>
	<20040809201556.GB9677@louise.pinerecords.com>
	<Pine.LNX.4.61.0408101258130.1290@boston.corp.fedex.com>
	<20040810075558.A14154@infradead.org>
	<20040810101640.GF9034@atrey.karlin.mff.cuni.cz>
	<4119F203.1070009@linux.intel.com>
	<20040811114437.A27439@infradead.org>
	<411A478E.1080101@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, Pavel Machek <pavel@suse.cz>,
        Jeff Chua <jeffchua@silk.corp.fedex.com>,
        Tomas Szepe
 <szepe@pinerecords.com>, netdev@oss.sgi.com,
        kernel list
 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <411A478E.1080101@linux.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> The driver supports (and defaults to) using firmware_class for loading the 
> firmware.  The driver also supports a legacy loading approach for folks that 
> have problems with using hotplug to load the firmware (which represents a fair 
> number of users).
> 

When and if you submit it into mainline, please remove the legacy loading
approach. Let's get to the cause of the problem and fix it, not bandaid
around it.

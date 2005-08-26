From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: Re: 2.6.12 Performance problems
Date: Fri, 26 Aug 2005 15:10:26 -0400
Message-ID: <20050826191026.GA8023@linux.intel.com>
References: <20050825142647.70995.qmail@web33314.mail.mud.yahoo.com> <430DF7FF.9080502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: danial_thom@yahoo.com, Jesper Juhl <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030209AbVHZTKw@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <430DF7FF.9080502@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2005 at 09:55:27AM -0700, Ben Greear wrote:
> Of course.  Never found a motherboard yet with decent built-in
> NICs.  The built-ins on this board are tg3 and they must be on
> a slow bus, because they cannot go faster than about 700Mbps
> (using big pkts).

There should be a number of decent boards out on the market these days.  
Try picking up one with a CSA gige adapter (a dedicated high bandwidth 
link to an e1000) or PCI Express (although that is harder to pick up on 
from the specifications of most motherboards).

		-ben

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Convert pppoe to new style protocol
Date: Wed, 18 Jun 2003 10:21:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.102122.59661992.davem@redhat.com>
References: <20030618080118.GC23037@wotan.suse.de>
	<20030618092126.A28100@almesberger.net>
	<20030618125159.GA15238@colin2.muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wa@almesberger.net, ak@muc.de, netdev@oss.sgi.com, mostrows@speakeasy.net,
   paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@colin2.muc.de
In-Reply-To: <20030618125159.GA15238@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@colin2.muc.de>
   Date: 18 Jun 2003 14:51:59 +0200,Wed, 18 Jun 2003 14:51:59 +0200

   On Wed, Jun 18, 2003 at 09:21:26AM -0300, Werner Almesberger wrote:
   > I know you find documentation unmanly, but maybe ...
   
   But what is the replacement? For moving over whole subsystems to 
   non linear skbs it's a bit late in the release...
   
We did it for all of netfilter just the other week, networking
development still continues, it's not too late.

Stop looking for excuses and just do the work Andi.

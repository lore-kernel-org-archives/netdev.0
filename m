From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Convert pppoe to new style protocol
Date: Wed, 18 Jun 2003 10:15:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.101535.112616670.davem@redhat.com>
References: <20030617220420.GA1169@averell>
	<20030617.150751.52901849.davem@redhat.com>
	<20030618080118.GC23037@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com, mostrows@speakeasy.net, paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030618080118.GC23037@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Wed, 18 Jun 2003 10:01:18 +0200

   I'm not going through the whole PPP layer now to audit it for non
   linear skb cleanliness...
   
Then you're not making it a compatible protocol.
And the printk will remain until someone fixes it.

If I could get Rusty to fixup _ALL_ of netfilter, I can get
you to fix just _ONE_ thing.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Do lazy gettimeofday for network packets
Date: Fri, 16 Apr 2004 13:50:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416135012.02c5f000.davem@redhat.com>
References: <20040409173554.49ecc736.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040409173554.49ecc736.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Apr 2004 17:35:54 +0200
Andi Kleen <ak@suse.de> wrote:

> This adds lazy network timestamping to 2.6.5.  skb->stamp is only filled in 
> when there is a consumer of network timestamps active in the system.

Ok, let's give this a try, I'll apply this.

Thanks Andi.

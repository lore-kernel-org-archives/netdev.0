From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Dump of TCP hang in established state
Date: 29 May 2003 21:57:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054238230.709.1.camel@tux.rsn.bth.se>
References: <1052841090.13492.20.camel@tux.rsn.bth.se>
	 <20030529.024114.78714066.davem@redhat.com>
	 <1054217010.757.39.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1054217010.757.39.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-05-29 at 16:03, Martin Josefsson wrote:

> > Can you reproduce this with the latest and greatest 2.5.x
> > sources?  I think we might have just nailed it...
> 
> I'll give it a spin later this evening if time permits.

I've just tested 2.5-bk and I can still reproduce it.
The wording of my mail might have been a bit wrong, I don't see complete
hangs, just ~2 minute stalls in ESTABLISHED state and then it continues
like nothing happened.

-- 
/Martin

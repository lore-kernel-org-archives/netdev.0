From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Dump of TCP hang in established state
Date: 21 May 2003 21:39:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1053545955.15182.12.camel@tux.rsn.bth.se>
References: <Mutt.LNX.4.44.0305141907210.9712-100000@excalibur.intercode.com.au>
	 <3ECBB522.9080101@us.ibm.com>  <1053545510.9476.9.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@intercode.com.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <1053545510.9476.9.camel@tux.rsn.bth.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-05-21 at 21:31, Martin Josefsson wrote:

> I've now tried my distcc stuff again. With TCP_CORK enabled I don't have
> any problem reproducing the hangs, 1 in 3 shows at least one hang. But
> so far I havn't been able to reproduce it with TCP_CORK disabled. I'll
> keep compiling a few more times, I've only run 10 compilations so far.

And of course I just got a hang without TCP_CORK just after sending the
mail.... sigh.

I'll see if I can get my tcpdump working with mmap-enabled libpcap
again...

-- 
/Martin

From: James Morris <jmorris@intercode.com.au>
Subject: Re: [2.6.0-test1-mm1] TCP connections over ipsec hang after a few
 seconds
Date: Mon, 21 Jul 2003 10:28:09 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307211026210.25753-100000@excalibur.intercode.com.au>
References: <6uwued6lzv.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sean Neakums <sneakums@zork.net>
In-Reply-To: <6uwued6lzv.fsf@zork.zork.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 20 Jul 2003, Sean Neakums wrote:

> > With the 100baseT configuration, are the systems on the same segment?
> 
> I'm connecting the two machines with a crossed-over cable.

I can't see anything strange here.  Can you confirm that you are seeing 
the pmtu messages for the crossover cable case?  If not, perhaps try 
manual configuration to rule out any racoon issues.


- James
-- 
James Morris
<jmorris@intercode.com.au>

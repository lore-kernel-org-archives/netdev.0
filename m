From: Sean Neakums <sneakums@zork.net>
Subject: Re: [2.6.0-test1-mm1] TCP connections over ipsec hang after a few
 seconds
Date: Mon, 21 Jul 2003 01:37:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6uu19g67gu.fsf@zork.zork.net>
References: <Mutt.LNX.4.44.0307211026210.25753-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0307211026210.25753-100000@excalibur.intercode.com.au> (James
 Morris's message of "Mon, 21 Jul 2003 10:28:09 +1000 (EST)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Morris <jmorris@intercode.com.au> writes:

> On Sun, 20 Jul 2003, Sean Neakums wrote:
>
>> > With the 100baseT configuration, are the systems on the same segment?
>> 
>> I'm connecting the two machines with a crossed-over cable.
>
> I can't see anything strange here.  Can you confirm that you are seeing 
> the pmtu messages for the crossover cable case?  If not, perhaps try 
> manual configuration to rule out any racoon issues.

Yes.  I checked the logs after I did the recreation, and the pmtu
messages are definitely showing up in the crossover case.  Will retry
with manual config.

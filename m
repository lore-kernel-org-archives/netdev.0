From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][1/4] b44: Ignore carrier lost errors
Date: Fri, 17 Sep 2004 12:00:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414B0A18.6020806@pobox.com>
References: <200408292218.00756.jolt@tuxbox.org> <200408292233.03879.jolt@tuxbox.org> <41324158.4020709@pobox.com> <200408292304.25447.jolt@tuxbox.org> <20040829164528.220424e5.davem@davemloft.net> <20040829234928.GA10060@havoc.gtf.org> <20040830061020.GA21270@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Schirmer <jolt@tuxbox.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20040830061020.GA21270@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Pietikainen wrote:
> On Sun, Aug 29, 2004 at 07:49:28PM -0400, Jeff Garzik wrote:
> 
>>>BTW, can someone fixup something for me?  Update MODULE_AUTHOR()
>>>please :-)  3/4 of this driver have been rewritten since I last
>>>touched it, heh.
>>
>>hehe.  I'll take care of it tonight when I queue Florian's stuff
>>to netdev-2.6 (and thus -mm, and thus eventually mainline).
> 
> And here's a resend of the bounce buffer patch, which should still
> apply on top of Florians (or without) just fine.
> 
> Signed-off-by: Pekka Pietikainen <pp@ee.oulu.fi>


patch applied to 2.6.x.

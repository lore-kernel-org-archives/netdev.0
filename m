From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tg3 locking update (with NAPI overtones)
Date: Wed, 27 Nov 2002 21:48:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE583F6.6040502@pobox.com>
References: <3DE406AE.2000908@pobox.com> <20021126.155144.43008660.davem@redhat.com> <3DE41779.9030804@pobox.com> <3DE4770B.3020701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DE406AE.2000908@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:

> Just out of curiosity, have any of you been able to reproduce
> any IRQ warnings under heavy loads with the tg3?  If I start
> up all ports of a 4-port tulip nic and also start the tg3
> (all running high speed), then I see a steady stream of
> complaints from the tg3....



Can you be more specific?  :)  Is it "poll already scheduled"?

Also:  is the tg3 sharing interrupts with any other device?

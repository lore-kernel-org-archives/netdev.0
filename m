From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] tg3 locking update (with NAPI overtones)
Date: Tue, 26 Nov 2002 23:40:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE4770B.3020701@candelatech.com>
References: <3DE406AE.2000908@pobox.com> <20021126.155144.43008660.davem@redhat.com> <3DE41779.9030804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Just out of curiosity, have any of you been able to reproduce
any IRQ warnings under heavy loads with the tg3?  If I start
up all ports of a 4-port tulip nic and also start the tg3
(all running high speed), then I see a steady stream of
complaints from the tg3....

At least one other person has seen the same and has emailed
me about it...

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

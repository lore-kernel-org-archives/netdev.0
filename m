From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Mon, 21 Oct 2002 09:25:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB42A90.1030709@candelatech.com>
References: <Pine.GSO.4.30.0210210850560.17911-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>, "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Patch looks fine except for the 300 number. What are you smoking?
> Please retain the original value.

The original value was 300, what do you want it to be?

(Check out what backlog defaults to, that is what is currently
used for the budget, in 2.4.20-pre9 at least.)

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

From: Ben Greear <greearb@candelatech.com>
Subject: Re: TG3 Performance Question
Date: Tue, 03 Dec 2002 12:44:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DED17C0.2010404@candelatech.com>
References: <D71BEAC27500D51199DF0002B328BA8D4FBEA2@ivexs1.intruvert.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Yan-Fa Li <yan@intruvert.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yan-Fa Li wrote:
> Hello
> 
> I'm trying to figure out some performance issues I have with
> the tg3 driver.

Are you sure your tg3 NIC is 66/64 PCI?  For 66/64, try an e1000 NIC,
you should be able to get 800Mbps or better out of it on such a system.

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

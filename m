From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  Networking:  send-to-self
Date: Tue, 17 Sep 2002 23:53:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D8822F4.6060201@candelatech.com>
References: <3D88217A.6070702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> This patch allows one to use the SO_BINDTODEVICE and a new ioctl against
> net_device objects to send and receive regular routed traffic between two

Gack, sorry for the last patch..it seems I screwed up the
patch process somehow.  Plz don't apply it as is!

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

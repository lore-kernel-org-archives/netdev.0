From: Ben Greear <greearb@candelatech.com>
Subject: Re: 8169 driver with NetGear GA511 card.
Date: Wed, 27 Oct 2004 18:58:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41805243.6090702@candelatech.com>
References: <41802CA8.8070900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <41802CA8.8070900@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:

> Kernel is 2.6.9 + my networking patches, compiled for pentium-M
>   NAPI for 8169 is enabled.
> 
> hardware is nx5000 laptop

I recompiled w/out NAPI and no more problems, though performance is
horrible (about 5Mbps bi-directional).

If the developer/maintainer could use one of these cardbus NICs, I'm
willing to donate one to help further development and stability.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

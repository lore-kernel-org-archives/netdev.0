From: Ben Greear <greearb@candelatech.com>
Subject: Re: PCI interrupt problem: e1000 & Super-Micro X6DVA motherboard
 (Solved)
Date: Tue, 29 Mar 2005 12:36:24 -0800
Message-ID: <4249BC48.6080608@candelatech.com>
References: <42421FF2.7050501@candelatech.com> <20050324081003.GA23453@xi.wantstofly.org> <42431734.3030905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42431734.3030905@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For posterity's sake:

The problem is evidently a hardware problem, and I'll have to
return the board to the manufacturer so they can solder on another
part.

So, if you want to use 4-port NICs in slot-5 of the SuperMicro X6DVA-EG
board, then purchase the X6DVA-4G instead, as the X6DVA-EG will NOT work.

Actually, anything that tries to use the 3rd PCI function will probably fail
as well...

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

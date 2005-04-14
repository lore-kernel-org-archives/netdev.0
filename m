From: Ben Greear <greearb@candelatech.com>
Subject: Re: PCI interrupt problem: e1000 & Super-Micro X6DVA motherboard
Date: Thu, 14 Apr 2005 13:34:17 -0700
Message-ID: <425ED3C9.5090600@candelatech.com>
References: <42421FF2.7050501@candelatech.com>	 <20050324081003.GA23453@xi.wantstofly.org>	 <42431734.3030905@candelatech.com> <5fc59ff305041411013fd35ed4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
In-Reply-To: <5fc59ff305041411013fd35ed4@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan wrote:

>Ben:
>
>Have you checked if the BIOS on the super micro machine is the latest
>and greatest. I have had interrupt routing issues very similar to the
>one you are describing due to a BIOS Interrupt Routing issue. Moving
>to newer BIOS fixed it.
>  
>

A new BIOS didn't help.  Super-Micro eventually reproduced the problem, 
and told me
the fix was to send the MB back to them so they could solder another part
onto it....  I haven't received the MB back yet so I don't know if they 
really
have a fix for it or not...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

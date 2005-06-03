From: Ben Greear <greearb@candelatech.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Thu, 02 Jun 2005 23:25:52 -0700
Message-ID: <429FF7F0.7050505@candelatech.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com>	 <efe3b00605051901022854653a@mail.gmail.com>	 <428CC958.1080909@candelatech.com>	 <efe3b0060505192225f3cf36e@mail.gmail.com>	 <428E0B3B.1090507@candelatech.com>	 <efe3b00605060222452675d8fc@mail.gmail.com>	 <429FF071.8040707@candelatech.com> <efe3b0060506022258519aa826@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kosta Todorovic <kostodo@gmail.com>
In-Reply-To: <efe3b0060506022258519aa826@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kosta Todorovic wrote:
> So intel gigE nics use standard tulip linux drivers that come shipped
> with a vanilla kernel?

No..forget about tulip.  It uses standard e1000 driver shipped with
vanilla kernel.  The BCM chipsets use standard drivers in the kernel
as well.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

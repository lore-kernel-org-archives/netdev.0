From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe RLT-8139 related)
Date: Thu, 5 Aug 2004 13:22:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805132233.A7430@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.44.0408041915510.14609-100000@silmu.st.jyu.fi> <41120882.40302@marcansoft.com> <41121237.4050305@marcansoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pasi Sjoholm <ptsjohol@cc.jyu.fi>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, akpm@osdl.org,
        netdev@oss.sgi.com, brad@brad-x.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Hector Martin <hector@marcansoft.com>
Content-Disposition: inline
In-Reply-To: <41121237.4050305@marcansoft.com>; from hector@marcansoft.com on Thu, Aug 05, 2004 at 12:55:51PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hector Martin <hector@marcansoft.com> :
[...]
> using a stabler TCP/IP stack. This one works OK. No problem so far... 
> anyway, even though it stopped and I had to restart the PS2 some times, 
> the PC has been receiving packets with no reboot whatsoever. I think 
> it's fixed :)

Ok, I'll send the final version of the patches for inclusion in -netdev
and/or -mm this evening. It will provide a broader testing.

--
Ueimor

From: bhartin@straus-frank.com
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Wed, 7 Apr 2004 08:43:18 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404070841530.28688@edp12.straus-frank.int>
References: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int>
 <20040126235559.A3832@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404041553010.6853@edp12.straus-frank.int>
 <20040405002028.A8125@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404061650310.20664@edp12.straus-frank.int>
 <20040407001815.C7833@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404061758570.17117@edp12.straus-frank.int>
 <20040407013841.A7978@electric-eye.fr.zoreil.com>
 <Pine.LNX.4.58.0404070014571.17117@edp12.straus-frank.int>
 <20040407112607.A17476@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040407112607.A17476@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I started a ping, and unplugged the network cable.  I got the 'r8169: 
eth0: Reset RTL8169s PHY' message about once every 11 to 15 seconds.  Once 
plugged back in, the connection recovered immediately.  I repeated this 
several times.  So, it's still generating the messages, but they seem to 
be harmless (at least for the few minutes I was testing this).

On Wed, 7 Apr 2004, Francois Romieu wrote:

> bhartin@straus-frank.com <bhartin@straus-frank.com> :
> [...]
> > The patch resolved the PHY messages, and I stress-tested the networking 
> > again--it's still stable.
> 
> Does it allow the link to be recovered if the cable is removed/plugde ?
> 
> --
> Ueimor
> 

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Mon, 5 Apr 2004 00:20:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405002028.A8125@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int> <20040126235559.A3832@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0404041553010.6853@edp12.straus-frank.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bhartin@straus-frank.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0404041553010.6853@edp12.straus-frank.int>; from bhartin@straus-frank.com on Sun, Apr 04, 2004 at 04:05:39PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bhartin@straus-frank.com <bhartin@straus-frank.com> :
[...]
> I haven't tried your latest set of patches because I haven't been able to 
> find the URL for them again (I got carried away cleaning up my bookmarks 
> recently).  Let me know if there are any newer ones you'd like for me to 
> try.

http://www.fr.zoreil.com/people/francois/misc/20040329-2.6.5-rc2-r8169.c-test.patch

It removes a possible loop in the Tx irq handler and should save some cpu
cycles as well. Apply against 2.6.5.

--
Ueimor

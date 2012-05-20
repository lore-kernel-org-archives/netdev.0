From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun
 Fire X4150(x86) and e1000e
Date: Sun, 20 May 2012 21:07:05 +0200
Message-ID: <1337540825.3361.0.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<4775d023592b876909aceb152f94aa01@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, davem@davemloft.net,
	Tom Herbert <therbert@google.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4775d023592b876909aceb152f94aa01@visp.net.lb>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 2012-05-20 at 21:53 +0300, Denys Fedoryshchenko wrote:
> >

> My kernel config http://www.nuclearcat.com/config_stall.txt
> 
> It is completely idle machine. I didn't notice any anomalies with 
> interrutps to
> compare with other servers (not Sun Fire). If there is anomalies with 
> interrupts
> (for example SMI), probably i should notice that even without BQL, but 
> this machine
> works very well and i didn't notice any latency without BQL.

You could try latencytop, I am not sure if some obvious things will
popup.




------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

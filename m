From: Jim Thompson <jim@netgate.com>
Subject: Re: d80211: ANNOUNCE: DadWifi,
	a port of MadWifi to d80211
Date: Wed, 18 Oct 2006 16:08:54 -1000
Message-ID: <70D11CC2-CCBD-4158-ABD4-38481B51F08B@netgate.com>
References: <20061018001403.GA22990@devicescape.com>
	<20061018101605.GA1767@infradead.org>
	<4536D265.3090307@mattb.net.nz>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4536D265.3090307@mattb.net.nz>
To: Matt Brown <matt@mattb.net.nz>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=madwifi-devel>
List-Post: <mailto:madwifi-devel@lists.sourceforge.net>
List-Help: <mailto:madwifi-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: madwifi-devel-bounces@lists.sourceforge.net
Errors-To: madwifi-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


On Oct 18, 2006, at 3:18 PM, Matt Brown wrote:

> Christoph Hellwig wrote:
>
>> Guys, why do you waste your time on doing stuff that's useless for  
>> most
>> of us, and that people can't even legally redistribute.
>
> Well that may be your opinion, but it's certainly not mine. We had  
> just
> discussed starting an in-house project to port the HAL to the d80211
> stack when David made his announcement.
>
> The reason? While we'd obviously prefer that the HAL didn't exist, if
> it's going to exist we would far rather that it had a common 80211  
> stack
> on top of it, so that we can easily switch to other chipsets and  
> retain
> the same featureset.
>
> Reducing the number of 80211 stacks in use in Linux is a great thing.

Of course, the net80211 stack in FreeBSD/NetBSD/OpenBSD is the only  
stack (as of 6.x, anyway),
and it supports ... multiple chipsets.

d80211 bought you nothing here.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

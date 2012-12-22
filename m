From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over Firewire
Date: Sat, 22 Dec 2012 07:03:34 +0100
Message-ID: <50D54D36.4070908@gmail.com>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org>
	<50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org>
	<20121222001230.3fe92bef@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20121222001230.3fe92bef@stein>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


>
> Can't we increase dev->addr_len for RFC 3146 interfaces?
> Can't we add another dev->type besides ARPHRD_IEEE1394 (RFC 2734)?
>
> Is a single dev instance transporting both IPv4 and IPv6 or will there be
> separate instances for those?
>

Right now there is a single dev instance for both IPv4 and IPv6. Two 
instances means there will be two separate device, doesn't it?

Stephan

------------------------------------------------------------------------------
LogMeIn Rescue: Anywhere, Anytime Remote support for IT. Free Trial
Remotely access PCs and mobile devices and provide instant support
Improve your efficiency, and focus on delivering more value-add services
Discover what IT Professionals Know. Rescue delivers
http://p.sf.net/sfu/logmein_12329d2d

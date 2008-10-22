From: Sanjoy Mahajan <sanjoy@MIT.EDU>
Subject: Re: e1000e fails after several S3 resumes (2.6.26
	Debian, TP T60)
Date: Wed, 22 Oct 2008 15:21:43 -0400
Message-ID: <E1KsjH5-0007Mg-0R@approx.mit.edu>
References: <4807377b0810220929v5906b42bgf9d63215370e5ab5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, NetDEV list <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: Your message of "Wed, 22 Oct 2008 09:29:21 PDT."
	<4807377b0810220929v5906b42bgf9d63215370e5ab5@mail.gmail.com>
	(sfid-20081022_141704_643135_AA4BDC9C)
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Thanks.  I'll use 'ethregs' and 'ethtool -d eth0' at the next
opportunity, though it might take a few weeks for the problem to recur,

> you'll have to build ethregs which I haven't tried to do on debian,
> but it should be possible.

It needed the 'libpci-dev' package and built smoothly.

> There is also lots of opportunity for BIOS bugs to be effecting things
> so please make sure that you have the latest bios.

It has BIOS 2.20 (79ETE3WW), the latest version when I last upgraded the
BIOS, but I see that 2.23 is available.  I'll upgrade as soon as I
remember how on a Windowless (TM) machine.

-Sanjoy

`Until lions have their historians, tales of the hunt shall always
 glorify the hunters.'  --African Proverb

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/

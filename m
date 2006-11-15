From: Michael Buesch <mb@bu3sch.de>
Subject: Re: ANNOUNCE: SFLC helps developers assess ar5k
	(enabling free Atheros HAL)
Date: Wed, 15 Nov 2006 20:26:25 +0100
Message-ID: <200611152026.26095.mb@bu3sch.de>
References: <20061115031025.GH3451@tuxdriver.com>
	<200611151942.14596.mb@bu3sch.de>
	<20061115192054.GA10009@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net, lwn@lwn.net
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061115192054.GA10009@tuxdriver.com>
Content-Disposition: inline
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

On Wednesday 15 November 2006 20:21, John W. Linville wrote:
> On Wed, Nov 15, 2006 at 07:42:14PM +0100, Michael Buesch wrote:
> 
> > Now that it seems to be ok to use these openbsd sources, should I port
> > them to my driver framework?
> > I looked over the ar5k code and, well, I don't like it. ;)
> > I don't really like having a HAL. I'd rather prefer a "real" driver
> > without that HAL obfuscation.
> 
> I don't think anyone likes the HAL-based architecture.  I don't think
> we will accept a HAL-based driver into the upstream kernel.

Yeah, wanted to hear that. ;)

> The point is that the ar5k is now safe to be used as a reference and
> source of information (and code, as appropriate) without copyright FUD.
> Distilling that information into a proper Linux driver is work that
> remains to be done.

Yeah, ok. I'll look what I can do. First I'll have to read the code.
and understand it. DMA stuff seems to be really obfuscated though
dozens of callbacks, heh. :)

-- 
Greetings Michael.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

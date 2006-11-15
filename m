From: "John W. Linville" <linville@tuxdriver.com>
Subject: ANNOUNCE: SFLC helps developers assess ar5k
	(enabling free Atheros HAL)
Date: Tue, 14 Nov 2006 22:10:26 -0500
Message-ID: <20061115031025.GH3451@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lwn@lwn.net, madwifi-devel@lists.sourceforge.net
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
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

It is my pleasure to announce that the SFLC [1] has assisted the ar5k
developers in evaluating the development history of Reyk Floeter's
OpenBSD reverse-engineered Atheros HAL, ar5k [2].  SFLC's assessment
leads to the conclusion that free software developers should not be
worried about using/extending ar5k or porting ar5k to other platforms.

In the past there were serious questions raised and even dire warnings
made about ar5k's copyright status.  The purpose of this statement
is to refute those claims and to publicly clarify ar5k's status
to developers.

SFLC has made independent inquiries with the OpenBSD team regarding the
development history of ar5k source.  The responses received provide
a reasonable basis for SFLC to believe that the OpenBSD developers
who worked on ar5k did not misappropriate code, and that the ar5k
implementation is OpenBSD's original copyrighted work.

This announcement should serve to remove the cloud which has prevented
progress towards an in-kernel driver for Atheros hardware.  This should
be of particular interest to those involved with the DadWifi project [3].

I'd like to take this opportunity to thank the folks at the SFLC for
their hard work, and I'd also like to personally thank Luis Rodriguez
for the role he played in coordinating contact between the SFLC and
the community at large.

Thanks!

John

[1] http://www.softwarefreedom.org/
[2] http://team.vantronix.net/ar5k/
[3] http://marc.theaimsgroup.com/?l=linux-netdev&m=116113064513921&w=2
-- 
John W. Linville
linville@tuxdriver.com

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

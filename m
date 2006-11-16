From: "Michael Renzmann" <madwifi@nospam.otaku42.de>
Subject: Re: ANNOUNCE: SFLC helps developers assess ar5k
 (enabling free Atheros HAL)
Date: Thu, 16 Nov 2006 12:55:43 +0100 (CET)
Message-ID: <2983.194.45.26.221.1163678143.squirrel@webmail.otaku42.de>
References: <20061115031025.GH3451@tuxdriver.com>
	<20061115192054.GA10009@tuxdriver.com> <1163619541.19111.6.camel@dv>
	<200611152102.26681.mb@bu3sch.de> <455BF908.6090006@otaku42.de>
	<40f31dec0611160207hcfd5069hc7763d1e99cccd7c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, madwifi-devel@lists.sourceforge.net,
	Michael Buesch <mb@bu3sch.de>, lwn@lwn.net,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
In-Reply-To: <40f31dec0611160207hcfd5069hc7763d1e99cccd7c@mail.gmail.com>
To: "Nick Kossifidis" <mickflemm@gmail.com>
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

Hi.

> Just in case you want to experiment, i have a working port of ar5k
> that works on madwifi-old before the BSD - HEAD merge...

Just to mention it: madwifi-old is no longer officially supported, and is
a bad ground to start working on IMO (at least for anything that goes
beyond a quick test).

Interested parties should start from trunk instead (which is at r1809 as
of now, by the way), or, even better, from the DadWifi branch. However, it
will require some work to get the OpenHAL working in either of them. I
suggest that related questions and discussions should be directed to the
madwifi-devel list, since they might be of little interest (yet) on netdev
or lkml.

The MadWifi project is happy to provide resources (such as r/w access to
our Subversion repository) to support these efforts, by the way. Please
contact me offlist for details.

Bye, Mike


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

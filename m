From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Streamline testing of 802.11 drivers
Date: Fri, 23 Jun 2006 16:33:45 -0400
Message-ID: <43e72e890606231333kd0fc534x5d08dad955d13bf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kishore Ramachandran <kishore@winlab.rutgers.edu>,
	Ivan Seskar <Seskar@winlab.rutgers.edu>
Return-path: <zd1211-devs-bounces@lists.sourceforge.net>
To: netdev@vger.kernel.org, zd1211-devs@lists.sourceforge.net
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/zd1211-devs>,
	<mailto:zd1211-devs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=zd1211-devs>
List-Post: <mailto:zd1211-devs@lists.sourceforge.net>
List-Help: <mailto:zd1211-devs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/zd1211-devs>,
	<mailto:zd1211-devs-request@lists.sourceforge.net?subject=subscribe>
Sender: zd1211-devs-bounces@lists.sourceforge.net
Errors-To: zd1211-devs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I've mentioned this to a few but here it is out to everyone. So as you
know we have a lot of work ahead of us for linux wireless development.
To help speed this up, we at Winlab, would like to start hosting a
testbed for linux wireless development, open to the public. Short term
goals would be to start off a couple of nodes for each driver
currently under development like bcm43xx, zd1211, rt2x00, ipw3945,
ipw2200 and the like, and a provide a set streamlined tests we can use
to really put to test the drivers and stacks.

This wouldn't be easy if we didn't have infrastructure but we already
do. Our grid consists of 400 nodes with 2 wireless cards each and 3
ethernet ports (one for control) --
http://orbit-lab.org/wiki/Tutorial/Testbed. 90% of our nodes use the
atheros 5213 chipset and the rest ipw2200s. We'd like to expand this
with the more wireless cards currently being worked on for linux.

Right now we have zome zd1211s so we'll start with that (I'll start
working on a port to d80211) but will try to accomodate other nodes as
we get more wireless cards. We will need some help too though, to
streamline the testing. If you have ideas or would like to contribute
please let me know. We can purchase wireless cards but if you already
have reliable confirmed wireless cards which can be used for putting
into the testbed let me know.

  Luis

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

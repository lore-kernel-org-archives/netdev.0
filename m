From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel
	PRO/Wireless 3945ABG
Date: Sat, 10 Feb 2007 11:39:34 -0500
Message-ID: <20070210163933.GA17140@tuxdriver.com>
References: <45CCE3CA.4050904@linux.intel.com>
	<20070210162254.GC25607@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Theodore Tso <tytso@mit.edu>,
	James Ketrenos <jketreno@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070210162254.GC25607@thunk.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, Feb 10, 2007 at 11:22:54AM -0500, Theodore Tso wrote:
> On Fri, Feb 09, 2007 at 01:12:42PM -0800, James Ketrenos wrote:
> > Please hold all questions until I am done with this email.  Thank you.
> > 
> > We are pleased to announce the availability of a new driver for the 
> > Intel PRO/Wireless 3945ABG Network Connection adapter.  This new driver 
> > uses the new d80211 subsystem previously only available as part of the 
> > wireless-dev tree.
> 
> Very cool!  Is it likely that d80211 and iwlwifi will be pushed into
> mainline in time for 2.6.21?

Hmmm...I think we need to spend a cycle or so in -mm.  2.6.22 seems
more likely for mainline.

John
-- 
John W. Linville
linville@tuxdriver.com

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

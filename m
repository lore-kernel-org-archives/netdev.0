From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel
	PRO/Wireless 3945ABG
Date: Tue, 13 Feb 2007 15:18:24 -0800
Message-ID: <45D24740.3070804@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com>	 <20070213181313.GA5350@ucw.cz>
	<1171391771.10344.93.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	ipw3945-devel@lists.sourceforge.net
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1171391771.10344.93.camel@johannes.berg>
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

Johannes Berg wrote:
> On Tue, 2007-02-13 at 18:13 +0000, Pavel Machek wrote:
> 
>> Yes... is there merged .git tree somewhere? I downloaded iwl git tree,
>> but it did not contain d80211 stack. I'm now downloading wireless-dev
>> git tree...
> 
> I would expect Intel to post patches some time soon to get into
> wireless-dev.
> 
> johannes

Some of the patches contained in the d80211-1.0.1 'pending/' directory 
have already been submitted to netdev in the past.  The rest will be 
submitted soon (I would have liked them to have been submitted a few 
weeks back, but that slipped through my task list)

The d80211 packages I've pushed to date haven't done a very good job of 
accounting regarding the pending/ directory.  Those were the patches our 
team here had been working with internally, and I wanted to get them out 
to the users ASAP.  I'm working to get better descriptions added to the 
headers of those patches, as well as adding a status line indicating 
when the patches were submitted to the mailing lists for discussion.

The goal is to only include patches in the d80211 tarballs which have 
been submitted for eventual in-tree inclusion.

James

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

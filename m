From: Christoph Hellwig <hch@infradead.org>
Subject: Re: d80211: ANNOUNCE: DadWifi,
	a port of MadWifi to d80211
Date: Wed, 18 Oct 2006 11:16:05 +0100
Message-ID: <20061018101605.GA1767@infradead.org>
References: <20061018001403.GA22990@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061018001403.GA22990@devicescape.com>
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

On Tue, Oct 17, 2006 at 05:14:29PM -0700, David Kimdon wrote:
> Hi,
> 
> DadWifi is a port of MadWifi to the d80211 stack.  It works now in
> managed and monitor mode, lightly tested.  Any card supported by
> MadWifi should be supported by DadWifi [1].  This allows a large
> number of cards to now take advantage of the d80211 stack.
> 
> DadWifi uses the same (binary only) hal as MadWifi and reuses much of
> the initialization, descriptor and interrupt processing code.

Guys, why do you waste your time on doing stuff that's useless for most
of us, and that people can't even legally redistribute.

Please switch to openhal or the openbsd code and we all owe you a lot of
beer at the next conference :)


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

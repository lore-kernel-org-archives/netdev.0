From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: d80211: ANNOUNCE: DadWifi,
	a port of MadWifi to d80211
Date: Tue, 17 Oct 2006 18:51:16 -0700
Message-ID: <20061017185116.1f14bd86@dads-laptop>
References: <20061018001403.GA22990@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: David Kimdon <david.kimdon@devicescape.com>
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

On Tue, 17 Oct 2006 17:14:29 -0700
David Kimdon <david.kimdon@devicescape.com> wrote:

> Hi,
> 
> DadWifi is a port of MadWifi to the d80211 stack.  It works now in
> managed and monitor mode, lightly tested.  Any card supported by
> MadWifi should be supported by DadWifi [1].  This allows a large
> number of cards to now take advantage of the d80211 stack.
> 
> DadWifi uses the same (binary only) hal as MadWifi and reuses much of
> the initialization, descriptor and interrupt processing code.
> 
> There is a subversion repository and mailing list available [2] for
> those wishing to try it out or help with development.
> 
> -David
> 
> 
> [1] : http://madwifi.org/wiki/Compatibility
> [2] : https://devicescape.org/projects/dadwifi/

I would consider this a BAD thing. You are creating a derived work
out of GPL and non-GPL software. This actually will hurt the possible acceptance
of the d80211 stack into the mainline kernel.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next] drivers/net
 Documentation/networking: Create directory intel_wired_lan
Date: Sun, 10 Oct 2010 17:41:27 -0700
Message-ID: <1286757687.11039.173.camel@Joe-Laptop>
References: <1286743352.11039.165.camel@Joe-Laptop>
	<20101010144440.0d7a69f9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org, PJ
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20101010144440.0d7a69f9@nehalam>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 2010-10-10 at 14:44 -0700, Stephen Hemminger wrote:
> On Sun, 10 Oct 2010 13:42:32 -0700
> Joe Perches <joe@perches.com> wrote:
> > Perhaps it's better to move drivers from the very populated
> > drivers/net directory into vendor specific directories similar
> > to the Atheros approach used for drivers/net/wireless/ath/
> > Move intel drivers and Documentation to separate directories
> Seems like it would introduce more confusion and trouble.

It would also allow common code to be consolidated from the
various drivers.



------------------------------------------------------------------------------
Beautiful is writing same markup. Internet Explorer 9 supports
standards for HTML5, CSS3, SVG 1.1,  ECMAScript5, and DOM L2 & L3.
Spend less time writing and  rewriting code and more time creating great
experiences on the web. Be a part of the beta today.
http://p.sf.net/sfu/beautyoftheweb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next] drivers/net
 Documentation/networking: Create directory intel_wired_lan
Date: Wed, 13 Oct 2010 15:28:26 -0700
Message-ID: <1287008906.1117.428.camel@Joe-Laptop>
References: <1286743352.11039.165.camel@Joe-Laptop>
	<AANLkTikVKufQRuMGd=cdig7ff4k2aw9Q1FWwMz3pgon-@mail.gmail.com>
	<1286841648.26045.17.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Don, e1000-devel <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1286841648.26045.17.camel@Joe-Laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2010-10-11 at 17:00 -0700, Joe Perches wrote:
> On Mon, 2010-10-11 at 16:52 -0700, Jeff Kirsher wrote:
> > On Sun, Oct 10, 2010 at 13:42, Joe Perches <joe@perches.com> wrote:
> > > Perhaps it's better to move drivers from the very populated
> > > drivers/net directory into vendor specific directories similar
> > > to the Atheros approach used for drivers/net/wireless/ath/
> > NAK
> > First, I think we need to keep the documentation in /Documentation/networking.
> > Second, the changes are extensive and would create a lot of regression testing.
> I don't see any actual changes here other than layout.
> What kind of regression testing do you think necessary?

Jeff?

What regression testing would actually be done?

Any new objects are trivially validated against existing
objects.

> > We have been looking at solutions like this for future
> > drivers/hardware and is on the list of items we are currently working
> > on, but feel it should not be made retroactively due to the regression
> > testing and massive changes that would need to be made.
> 
> Might as well start somewhere.




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

From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: No link on e1000e with 2.6.35.3 and ThinkPad T60
Date: Sun, 12 Sep 2010 23:04:39 +0200
Message-ID: <20100912210439.GA17799@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de>
	<20100824094524.GA17608@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A136600821444B@rrsmsx501.amr.corp.intel.com>
	<20100826112732.GA15559@torres.zugschlus.de>
	<20100826171442.GA22941@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A13660082E9090@rrsmsx501.amr.corp.intel.com>
	<20100904063305.GA18734@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A13660085FFA1B@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A13660085FFA1B@rrsmsx501.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Sep 07, 2010 at 01:05:45PM -0600, Tantilov, Emil S wrote:
> Marc Haber wrote:
> > I can give you ssh access to mine if you want to. Do you have IPv6
> > connectivity? If you want me to, send me your ssh key.
> 
> Is your traffic mostly over IPv6? That maybe a clue as there has been
> a lot of changes in the IPv6 code in recent kernels.

No, IPv6 is just some kind of luxury. The majority of work is done via
IPv4. It is just easier to make the box accessible from the outside
via IPv6 since it's IPv4 connectivity is natted.

> At this point we need to start looking into details. Especially if you
> can come up with some sort of test that would consistently reproduce
> the hang. I should be able to repro it on my system if it is a generic
> issue.

I will try doing so. At the moment, I am pretty much traveling five
days a week and do not have much opportunity to use the wired
Ethernet, but I haven't seen the crashes recently. So it might as well
be fixed in 2.6.35.4.

> I would also repeat my request to open a bug at e1000.sf.net as there
> has been a lot of info exchanged in email and it will be easier to
> follow if it is in one place.

I will do that as soon as I see the issue again.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190

------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing
http://p.sf.net/sfu/novell-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

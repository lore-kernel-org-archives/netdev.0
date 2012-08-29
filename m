From: Kelvie Wong <kelvie@ieee.org>
Subject: Re: Intel 82574L hang when sending short ethernet
	packets at 100BaseT
Date: Wed, 29 Aug 2012 13:46:10 -0700
Message-ID: <CAK2bC5oMnxerNYsgoD7WFJ6p84=BqaZLFdt+GdO91tF0gmyg2w@mail.gmail.com>
References: <87k3whtqci.fsf@kwong-desktop.i-did-not-set--mail-host-address--so-tickle-me>
	<061C8A8601E8EE4CA8D8FD6990CEA89130DB6077@ORSMSX102.amr.corp.intel.com>
	<CAK2bC5q5NcWj5vsmPB1GekUpON_R_mTWgkEAYBgBZSJZ30GcDg@mail.gmail.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89130DB60AC@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kelvie Wong <kwong@wurldtech.com>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89130DB60AC@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Aug 29, 2012 at 1:29 PM, Dave, Tushar N <tushar.n.dave@intel.com> wrote:
> I'm already aware of this issue on PCI/PCI-X parts and e1000 SF driver does have this WA implemented. The patch for upstream e1000 driver is submitted too which will be accepted soon.
> I will check with team and see if we need similar WA for PCIe part(s)!

Ah, I see. Thanks for the clarification.
-- 
Kelvie Wong

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

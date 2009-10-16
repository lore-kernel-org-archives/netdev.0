From: Richard Scobie <richard@sauce.co.nz>
Subject: Re: behaviour question for igb on nehalem box
Date: Sat, 17 Oct 2009 11:15:37 +1300
Message-ID: <4AD8F089.9010602@sauce.co.nz>
References: <4ACF8466.5030309@nortel.com>	<alpine.WNT.2.00.0910091250440.5328@jbrandeb-desk1.amr.corp.intel.com>	<4ACFB9DF.9080909@nortel.com>	<4ACFC52F.4050509@intel.com>
	<4ACFCBE8.7060108@intel.com> <4AD4B9BB.3010209@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-list <e1000-devel@lists.sourceforge.net>,
	Linux Network Development list <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4AD4B9BB.3010209@nortel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I'm have just put together a Nehalem system (1 x Xeon), 
2.6.30.8-64.fc11.x86_64, which has quad onboard 82576 and noticed during 
testing using just a single interface, that the RX queues on the other 3 
were receiving interrupts - observed in /proc/interrupts.

Is this normal behaviour?

Regards,

Richard

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference

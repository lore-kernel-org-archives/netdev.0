From: Amit Kucheria <amit.kucheria@nokia.com>
Subject: Re: [RFC] Runtime power management on	ipw2100
Date: Wed, 31 Jan 2007 15:24:36 +0200
Message-ID: <1170249876.6746.43.camel@amit-laptop>
References: <20070131075249.GA22115@srcf.ucam.org>
	<p731wlbphz3.fsf@bingen.suse.de> <20070131102744.GA24424@srcf.ucam.org>
	<200701311148.20777.ak@suse.de> <1170244400.6746.31.camel@amit-laptop>
	<20070131130447.GF19643@elf.ucw.cz>
Reply-To: amit.kucheria@nokia.com
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, ipw2100-devel@lists.sourceforge.net,
   linux-pm@lists.osdl.org, ext Andi Kleen <ak@suse.de>,
   netdev@vger.kernel.org
To: ext Pavel Machek <pavel@suse.cz>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <20070131130447.GF19643@elf.ucw.cz>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-31 at 14:04 +0100, ext Pavel Machek wrote:
> On Wed 2007-01-31 13:53:20, Amit Kucheria wrote:
> > =

> > Yes. Low power states without ability to respond to wakeup interrupts
> > would be broken behaviour generally.
> =

> Do you realy expect wifi to save significant ammount of power, while
> still listening for packets on wireless network?
> 									Pavel

>From N800 specs (not meant as a shameless plug):

Continuous WLAN browsing:  upto 3.5 hrs
Always Online WLAN (idle but respond to VoIP calls): upto 2 days
Standby time(no WLAN):  upto 12 days

So with the right hardware, yes, you can listen and still save power.

Regards,
Amit

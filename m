From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: Transmit timeout with E1000
Date: Wed, 11 Jan 2006 14:22:08 +0100
Message-ID: <20060111132208.GA2332@harddisk-recovery.nl>
References: <20060110151254.GA24273@harddisk-recovery.com> <Pine.WNT.4.63.0601100929570.1360@jbrandeb-desk.amr.corp.intel.com> <20060111125946.GA18203@harddisk-recovery.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Rogier Wolff <R.E.Wolff@BitWizard.nl>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <20060111125946.GA18203@harddisk-recovery.nl>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2006 at 01:59:46PM +0100, Erik Mouw wrote:
> On Tue, Jan 10, 2006 at 09:46:29AM -0800, Jesse Brandeburg wrote:
> > sorry to hear you're having a problem, and cool, thanks for the test,
> > we'll have to try it here.  We've classically had problems reproducing the
> > athlon based hangs.
> 
> Athlon based or Athlon-on-VIA-KT400 based? We have an E1000 dual
> interface server adapter on a dual Athlon with AMD 762 chipset running
> fine, and also the same kind of adapter on a dual Athlon64 with
> AMD-8111 chipset running fine.

FWIW: I just found out that we have a desktop with similar hardware
that doesn't have TX timeouts.

Same mainboard (Asrock K7VT4APro), same AMD Athlon XP 2000+ CPU (though
it appears to be underclocked at 1250 MHz instead of 1666 MHz, probably
a jumper problem), different E1000 adapter (8086:1076 vs. 8086:107c),
different kernel version (2.4.24 vs. 2.6.15).


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
| Data lost? Stay calm and contact Harddisk-recovery.com


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click

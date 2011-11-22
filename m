From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Tue, 22 Nov 2011 08:54:12 -0500
Message-ID: <20111122135412.GA29905@phenom.dumpdata.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Florian Mickler <florian@mickler.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <201111212249.31196.rjw@sisk.pl>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

> Subject    : Regression in 3.1 causes Xen to use wrong idle routine
> Submitter  : Stefan Bader <stefan.bader@canonical.com>
> Date       : 2011-10-26 10:24
> Message-ID : 4EA7DFD1.9060608@canonical.com
> References : http://marc.info/?l=linux-acpi&m=131962467924564&w=2

The patch mentioned in http://mid.gmane.org/20111115144004.GE22675@phenom.dumpdata.com 
should do it. But the patch needs an Ack from ACPI/x86 folks.

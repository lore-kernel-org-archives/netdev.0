From: Rodolfo Giometti <giometti@enneenne.com>
Subject: Re: [PATCH V7 5/8] ptp: Added a brand new class driver for ptp
 clocks.
Date: Thu, 16 Dec 2010 17:08:05 +0100
Message-ID: <20101216160804.GI10333@enneenne.com>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <55b3188e735c3ce51608eef7926136d789182aa3.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55b3188e735c3ce51608eef7926136d789182aa3.1292512461.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 16, 2010 at 04:44:24PM +0100, Richard Cochran wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> presented as a standard POSIX clock.
> 
> The ancillary clock features are exposed in two different ways, via
> the sysfs and by a character device.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Regarding the PPS subsystem it looks ok for me.

Acked-by: Rodolfo Giometti <giometti@linux.it>

Ciao,

Rodolfo

-- 

GNU/Linux Solutions                  e-mail: giometti@enneenne.com
Linux Device Driver                          giometti@linux.it
Embedded Systems                     phone:  +39 349 2432127
UNIX programming                     skype:  rodolfo.giometti
Freelance ICT Italia - Consulente ICT Italia - www.consulenti-ict.it

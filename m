From: David Miller <davem@davemloft.net>
Subject: Re: 3.3-rc4+: Reported regressions from 3.2
Date: Thu, 23 Feb 2012 18:28:25 -0500 (EST)
Message-ID: <20120223.182825.1031311733171854243.davem@davemloft.net>
References: <y44pDJ8xoDC.A.08E.h8rRPB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	florian@mickler.org, akpm@linux-foundation.org,
	kernel-testers@vger.kernel.org, torvalds@linux-foundation.org,
	linux-pm@lists.linux-foundation.org, maciej.rutecki@gmail.com
To: rjw@sisk.pl
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <y44pDJ8xoDC.A.08E.h8rRPB@chimera>
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

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Thu, 23 Feb 2012 23:51:20 +0100 (CET)

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=42776
> Subject		: OF-related boot crash in 3.3.0-rc3-00188-g3ec1e88
> Submitter	: Meelis Roos <mroos@linux.ee>
> Date		: 2012-02-13 7:45 (11 days old)
> Message-ID	: <alpine.SOC.1.00.1202130942030.1488@math.ut.ee>
> References	: http://marc.info/?l=linux-kernel&m=132911916331615&w=2

Potential workaround/fix at:

http://marc.info/?l=linux-kernel&m=132993294018762&w=2

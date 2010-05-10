From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: 2.6.34-rc6-git6: Reported regressions from 2.6.33
Date: Mon, 10 May 2010 12:07:24 -0400
Message-ID: <20100510160724.GA31416@elliptictech.com>
References: <10aqDnTJcLO.A.mLE.48y5LB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>,
        Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <10aqDnTJcLO.A.mLE.48y5LB@chimera>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 23:13 Sun 09 May     , Rafael J. Wysocki wrote:
> This message contains a list of some regressions from 2.6.33,
> for which there are no fixes in the mainline known to the tracking team.
> If any of them have been fixed already, please let us know.
> 
> If you know of any other unresolved regressions from 2.6.33, please let us
> know either and we'll add them to the list.  Also, please let us know
> if any of the entries below are invalid.

Seems that

  r600 CS checker rejects narrow FBO renderbuffers
  https://bugs.freedesktop.org/show_bug.cgi?id=27609

never got added to the list.  It is still an issue as of 2.6.34-rc7.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

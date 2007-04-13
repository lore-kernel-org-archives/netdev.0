From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [3/4] 2.6.21-rc5: known regressions (v2)
Date: Fri, 13 Apr 2007 18:32:14 +0200
Message-ID: <6bffcb0e0704130932q215a2deby91141c8d3c78bde7@mail.gmail.com>
References: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org>
	<20070330213220.GO14134@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
   netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
   Andrew Morton <akpm@linux-foundation.org>, linux-pm@lists.osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Adrian Bunk" <bunk@stusta.de>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <20070330213220.GO14134@stusta.de>
Content-Disposition: inline
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

On 30/03/07, Adrian Bunk <bunk@stusta.de> wrote:
> Subject    : suspend to disk hangs  (skge)
> References : http://lkml.org/lkml/2007/3/27/212
> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Caused-By  : Stephen Hemminger <shemminger@linux-foundation.org>
>              commit a504e64ab42bcc27074ea37405d06833ed6e0820
> Status     : unknown

This problem is fixed in 2.6.21-rc6-git5 (commit
692412b31ffb5df00197ea591dd635fc07506c02).

Huge thanks to Stephen.

Regards,
Michal

-- =

Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)

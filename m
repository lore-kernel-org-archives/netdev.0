From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/3] XFRM: RFC4303 compliant auditing
Date: Fri, 21 Dec 2007 09:22:23 -0500
Message-ID: <200712210922.23386.paul.moore@hp.com>
References: <20071221.014310.155404661.davem@davemloft.net>
	<200712210851.22521.paul.moore@hp.com>
	<20071221.060241.19624191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20071221.060241.19624191.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Friday 21 December 2007 9:02:41 am David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Fri, 21 Dec 2007 08:51:22 -0500
>
> > Ah, looks like I may not be crazy after all!  It looks like the XFRM
> > patches from Masahide NAKAMURA were pulled into net-2.6.25 just before
> > mine last night which caused my patches to conflict ...
>
> Sorry.  I had double checked and was going to rework your patches
> by hand if that was the case, but for some reason I didn't see
> his patches as being the culprit causing the rejects when I
> checked things out.
>
> I must have looked over the history correctly.

No harm, no foul.  I've just about finished respining the patches, expect them 
shortly ...

-- 
paul moore
linux security @ hp

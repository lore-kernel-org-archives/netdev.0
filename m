From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] XFRM: SPD auditing fix to include the
	netmask/prefix-length
Date: Sun, 2 Dec 2007 23:52:09 -0500
Message-ID: <200712022352.09627.paul.moore@hp.com>
References: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net>
	<200711300951.48964.paul.moore@hp.com>
	<20071201122834.GA15910@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Joy Latten <latten@us.ibm.com>, linux-audit@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20071201122834.GA15910@gondor.apana.org.au>
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

On Saturday 01 December 2007 7:28:34 am Herbert Xu wrote:
> On Fri, Nov 30, 2007 at 09:51:48AM -0500, Paul Moore wrote:
> > Steve and/or Joy, could we get a verdict on this issue?  The lack of a
> > netmask in the SPD audit messages is pretty serious so I'd like to see
> > this fixed as soon as possible.
>
> I'll take the resounding silence as an indication of approval :)
>
> Patch applied to net-2.6.25.  Thanks Paul.

Thanks Herbert.  If I hear any grumblings from the audit folks I'll send out 
another patch to make the prefix length a permanent fixture.

-- 
paul moore
linux security @ hp

From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v3 3/3] ARM: shmobile: genmai: Enable r7s72100-ether
Date: Wed, 8 Jan 2014 09:07:09 +0900
Message-ID: <20140108000709.GC5136@verge.net.au>
References: <1389061635-4083-1-git-send-email-horms+renesas@verge.net.au>
 <1389061635-4083-4-git-send-email-horms+renesas@verge.net.au>
 <52CC7C1B.20807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52CC7C1B.20807@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 08, 2014 at 02:13:47AM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 07-01-2014 6:27, Simon Horman wrote:
> 
>    You've removed RFC but still haven't signed off. :-)
> 
> >---
> >v2
> >* As suggested by Magnus Damm and Sergei Shtylyov
> >   - r7s72100 ethernet is not gigabit so do not refer to it as such
> 
> >* As suggested by Sergei Shtylyov
> >   - set no_ether_link as there is no LINK signal documented
> >     in the manual
> 
>    I'm OK with the patch, you can add my Acked-by.

Thanks, will do.

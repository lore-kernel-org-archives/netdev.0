From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Thu, 9 Sep 2010 11:58:09 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009091152300.2477@localhost6.localdomain6>
References: <cover.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1283504065.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2010, Richard Cochran wrote:

> Recently on the lkml, we discussed how to allow adjustment of posix
> clocks. I have tried to understand and implement the ideas expressed
> in the various threads.

Cc'ing the relevant maintainers to such discussions and patches might
be helpful. Seems I need to do some archive digging.

> If there is agreement on this approach, I will resubmit these two
> patches as part of a longer series, including support for a new kind
> of hardware clock, so you can see how it all fits together. But first,
> I would like to concentrate on the new syscall itself.
> 
> The patches are against a recent net-next tree. Please don't worry if
> the syscall tables are not quite up to date. I can fix that later.

How is this related to net-next ? 

Thanks,

	tglx

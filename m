From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v9 0/6] Add eBPF hooks for cgroups
Date: Fri, 25 Nov 2016 18:15:44 -0500 (EST)
Message-ID: <20161125.181544.427209012805564830.davem@davemloft.net>
References: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org,
        fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479916350-28462-1-git-send-email-daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Date: Wed, 23 Nov 2016 16:52:24 +0100

> This is v9 of the patch set to allow eBPF programs for network
> filtering and accounting to be attached to cgroups, so that they apply
> to all sockets of all tasks placed in that cgroup. The logic also
> allows to be extendeded for other cgroup based eBPF logic.
> 
> Again, only minor details are updated in this version.

Series applied, thanks for working so hard to see this through
to the very end.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Sat, 18 Jan 2014 16:50:53 -0800
Message-ID: <CAM_iQpVhwTRHXkcY_-j9q=-xn=O1Cvd+aQ1VKeKWnv1GZuttpQ@mail.gmail.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
	<CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
	<52D97746.1040408@redhat.com>
	<CAM_iQpUoQcHpQJn-nYp9mO+XXMmXSjFxy3ASwchAH-qECoz9OA@mail.gmail.com>
	<1390065511.31367.535.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpV5NO5YZkQ3dSj_GYhNE2jUdwcYgbX1uNaFua71a266HQ@mail.gmail.com>
	<52DADA65.3030508@redhat.com>
	<CAM_iQpWymPmN1yBFW9XQv71ZxeGACMuR_TrXNOmFgj3o7+v+zA@mail.gmail.com>
	<CAM_iQpU6LW2a=kfryrvbZvUQ_+T_9n0dnoxEw_0G_J9hQfNHSQ@mail.gmail.com>
	<52DB1E19.5040909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35964 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaASAuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 19:50:54 -0500
Received: by mail-ob0-f181.google.com with SMTP id va2so2234185obc.40
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 16:50:54 -0800 (PST)
In-Reply-To: <52DB1E19.5040909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 4:36 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
> Cong, I truly do __not__ care who is what or who isn't. I do care
> that the code is fine. Sure, next time I'll ask, or better, just
> give feedback; sorry for how this went, it was not my intention.

Apologies accepted. Let's build a better community!

Thanks.

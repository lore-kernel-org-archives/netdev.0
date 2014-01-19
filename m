From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Sun, 19 Jan 2014 01:36:41 +0100
Message-ID: <52DB1E19.5040909@redhat.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com> <CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com> <52D97746.1040408@redhat.com> <CAM_iQpUoQcHpQJn-nYp9mO+XXMmXSjFxy3ASwchAH-qECoz9OA@mail.gmail.com> <1390065511.31367.535.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpV5NO5YZkQ3dSj_GYhNE2jUdwcYgbX1uNaFua71a266HQ@mail.gmail.com> <52DADA65.3030508@redhat.com> <CAM_iQpWymPmN1yBFW9XQv71ZxeGACMuR_TrXNOmFgj3o7+v+zA@mail.gmail.com> <CAM_iQpU6LW2a=kfryrvbZvUQ_+T_9n0dnoxEw_0G_J9hQfNHSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbaASAgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jan 2014 19:36:49 -0500
In-Reply-To: <CAM_iQpU6LW2a=kfryrvbZvUQ_+T_9n0dnoxEw_0G_J9hQfNHSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2014 12:48 AM, Cong Wang wrote:

> I do understand you want to be the author, next time, just tell me
> before you do, I will let you be whatever you want (if I can).
> That's all.
>
> REPEAT: I don't mind who fixes it, I DO mind you did it without
> asking me first.

Cong, I truly do __not__ care who is what or who isn't. I do care
that the code is fine. Sure, next time I'll ask, or better, just
give feedback; sorry for how this went, it was not my intention.

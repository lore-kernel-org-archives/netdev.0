From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Sat, 18 Jan 2014 15:32:24 -0800
Message-ID: <CAM_iQpWymPmN1yBFW9XQv71ZxeGACMuR_TrXNOmFgj3o7+v+zA@mail.gmail.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
	<CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
	<52D97746.1040408@redhat.com>
	<CAM_iQpUoQcHpQJn-nYp9mO+XXMmXSjFxy3ASwchAH-qECoz9OA@mail.gmail.com>
	<1390065511.31367.535.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpV5NO5YZkQ3dSj_GYhNE2jUdwcYgbX1uNaFua71a266HQ@mail.gmail.com>
	<52DADA65.3030508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:55663 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbaARXcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 18:32:25 -0500
Received: by mail-oa0-f43.google.com with SMTP id h16so5661964oag.16
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 15:32:24 -0800 (PST)
In-Reply-To: <52DADA65.3030508@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 11:47 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> I do care that this gets fixed asap! Clearly, it seems it was an honest
> mistake to do so.

Why??? Even for stable, you don't have to be hurry. That's all.

From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH iproute2] vxlan: add ipv6 support
Date: Fri, 19 Apr 2013 19:36:58 +0800
Message-ID: <1366371418.5117.6.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-7-git-send-email-amwang@redhat.com>
	 <20130418155508.010c7c09@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968084Ab3DSLhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 07:37:09 -0400
In-Reply-To: <20130418155508.010c7c09@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 15:55 -0700, Stephen Hemminger wrote:
> On Wed, 17 Apr 2013 13:10:23 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > ---
> >  include/linux/if_link.h |    2 ++
> >  ip/iplink_vxlan.c       |   45 ++++++++++++++++++++++++++++++++++++++-------
> >  2 files changed, 40 insertions(+), 7 deletions(-)
> > 
> 
> Resubmit after net-next is merged to upstream.

Sure, I carry it for completeness.

From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v10 11/11] ipv6: Add generic UDP Tunnel
 segmentation
Date: Fri, 30 Aug 2013 16:16:03 +0800
Message-ID: <1377850563.2591.11.camel@cr0>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	 <1377667379-2315-12-git-send-email-amwang@redhat.com>
	 <CALnjE+p87D301m8oJ=rkJap44zcPkVp=YkThUT70fW1kkrQ9AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529Ab3H3IQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 04:16:16 -0400
In-Reply-To: <CALnjE+p87D301m8oJ=rkJap44zcPkVp=YkThUT70fW1kkrQ9AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 10:55 -0700, Pravin Shelar wrote:
> On Tue, Aug 27, 2013 at 10:22 PM, Cong Wang <amwang@redhat.com> wrote:
> > From: Cong Wang <amwang@redhat.com>
> >
> > Similar to commit 731362674580cb0c696cd1b1a03d8461a10cf90a
> > (tunneling: Add generic Tunnel segmentation)
> >
> Can we factor out ipv4-udp-tunnel code so that there is no duplicating code?

Probably we can, but it will make code review harder? Or you mean doing
it in a separated patch? If you insist, I can do it in a separated
patch.

Thanks.

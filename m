From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Thu, 19 Nov 2015 17:40:16 +0200
Message-ID: <CAJ3xEMiSwVhUCTYcH+nWWBqrSwiykqsBFUZtBkirQtzsXVVL4A@mail.gmail.com>
References: <56435508.9070802@mellanox.com>
	<CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
	<CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
	<CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
	<CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
	<CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38148 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758336AbbKSPkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 10:40:16 -0500
Received: by igbxm8 with SMTP id xm8so66311375igb.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 07:40:16 -0800 (PST)
In-Reply-To: <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 14, 2015 at 8:45 AM, Joe Stringer <joestringer@nicira.com> wrote:
> On 13 November 2015 at 06:46, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:

>>> I agree that this UNSPEC issue on v2.3 could do with a bit of a closer
>>> look. I'll see if I can find some time for it. Alternatively if you're
>>> willing and have bandwith, I'd be curious if it's related to the
>>> masked set field feature introduced in Linux-4.0.

>> so what would you suggest here? run with 3.19 or earlier?

> On second thought, I think if it were related to that then userspace
> v2.4 would not exhibit the problem. I'd have to dig in to see why it
> occurs.

Any findings?

Or.

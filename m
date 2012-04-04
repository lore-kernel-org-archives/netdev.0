From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V6 7/8] net/dcb: Add an optional max rate attribute
Date: Thu, 5 Apr 2012 00:56:09 +0300
Message-ID: <CAJZOPZKLtvtfD+o81V0Ezs7NSeTnmp-dBtHPhmziypHkpyOWtw@mail.gmail.com>
References: <1333537084-9186-1-git-send-email-amirv@mellanox.com>
	<1333537084-9186-8-git-send-email-amirv@mellanox.com>
	<4F7C6D3C.7070807@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:56695 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756897Ab2DDV4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 17:56:11 -0400
Received: by lahj13 with SMTP id j13so788708lah.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 14:56:10 -0700 (PDT)
In-Reply-To: <4F7C6D3C.7070807@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 4, 2012 at 6:48 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> And I think the last comment. We really should have a comment here describing
> what the tc_maxrate field is. Its described in the commit log but its much
> harder for implementers to get it wrong when the struct is annotated.

Okay, John, sure, we can add that, so just to make sure, from your
side the series is okay once this comment is added, correct?

Or.

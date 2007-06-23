From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer
 dereferencing, take 2
Date: Sat, 23 Jun 2007 09:54:46 -0700
Message-ID: <20070623095446.c1a9c697.akpm@linux-foundation.org>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
	<a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: "pradeep singh" <pradeep.rautela@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52136 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755352AbXFWREl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 13:04:41 -0400
In-Reply-To: <a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 21 Jun 2007 18:48:30 +0530 "pradeep singh" <pradeep.rautela@gmail.com> wrote:
> Hi,
> My mistake.
> Resending after reformatting the patch by hand.
> Looks like gmail messes the plain text patches.
> 

That's still mangled so I typed it in again.

Please always include a full changlog with each version of a patch.

I do not know what this patch does - please provide a changelog.  In this
case it should tell us whether and how this null pointer deref is actually
occuring and if so, why.

As well as a full description of the problem which it solves, a changelog
should also describe _how_ it solved it, but that is sufficiently obvious
in this case.


Thanks.

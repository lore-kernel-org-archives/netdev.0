From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers: connector: fixed coding style issues
Date: Sat, 14 Jul 2012 14:56:20 -0700
Message-ID: <1342302980.8377.43.camel@joe2Laptop>
References: <1342297608-6872-1-git-send-email-valentin.ilie@gmail.com>
	 <1342298026.8377.33.camel@joe2Laptop>
	 <CAHuBVBYXAj7OUgo3UmLERbcmBw-sK8c66TuCq_7Fsp=CVzzYSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org
To: Valentin Ilie <valentin.ilie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44494 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752165Ab2GNV4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 17:56:21 -0400
In-Reply-To: <CAHuBVBYXAj7OUgo3UmLERbcmBw-sK8c66TuCq_7Fsp=CVzzYSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-15 at 00:51 +0300, Valentin Ilie wrote:
> On 14 July 2012 23:33, Joe Perches <joe@perches.com> wrote:
> > I think it would be better written by hoisting the
> > function outside the if like [..]
> 
> OK.
> 
> Should I submit the whole patch again (with that change) or just
> another small patch that does just that?

It's generally better to reply to the original patch
with [PATCH V2] with the entire patch content updated.

btw: there's a missing a semicolon in what I posted.

Also add a changelog after the --- so the new patch
email looks like:

Subject: [PATCH V2] drivers: connectors: etc

Patch description...

Signed-off-by: etc
---
v2: Updated to do whatever

actual patch...

cheers, Joe

From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH iproute2 v2 3/3] lwtunnel: implement support for ip6
 encap
Date: Fri, 18 Dec 2015 09:42:05 +0100
Message-ID: <1450428125.8905.1.camel@redhat.com>
References: <cover.1450267709.git.pabeni@redhat.com>
	 <25335db6a83c31df4a13bfff8dfc4c359f8f1ef9.1450267709.git.pabeni@redhat.com>
	 <20151217173040.318924d1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Benc <jbenc@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932099AbbLRImI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 03:42:08 -0500
In-Reply-To: <20151217173040.318924d1@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-17 at 17:30 -0800, Stephen Hemminger wrote:
> On Wed, 16 Dec 2015 13:22:28 +0100
> Paolo Abeni <pabeni@redhat.com> wrote:
> 
> > Currently ip6 encap support for lwtunnel is missing.
> > This patch implement it, mostly duplicating the ipv4 parts.
> > 
> > Also be sure to insert a space after the encap type, when
> > showing lwtunnel, to avoid the tunnel type and the following
> > argument being merged into a single word.
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> Patch does not apply cleanly. Probably because of recent changes to lwtunnel
> and tunnel related arguement parsing.

Sorry, my bad: my local tree was not very up to date. I'll rebase and
resend.

Cheers,

Paolo

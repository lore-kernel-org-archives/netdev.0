From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 2 Jun 2015 23:43:24 +0200
Message-ID: <20150602214324.GB5842@pox.localdomain>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
 <20150602000603.GB18435@pox.localdomain>
 <556DAF9A.9050505@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35420 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbbFBVn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:43:27 -0400
Received: by wgme6 with SMTP id e6so150932342wgm.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 14:43:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <556DAF9A.9050505@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/15 at 02:28pm, Robert Shearman wrote:
> Nesting attributes inside the RTA_ENCAP blob should be supported by the
> patch series today. Something like this:

Sure. I'm not seeing such a construct for the MPLS case yet.

I'm happy to rebase my patches on top of your nexthop implementation.
It is definitely superior. Are you maintaining a git tree somewhere?

From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 0/3] SCTP fixes
Date: Tue, 14 Oct 2014 23:06:32 -0400
Message-ID: <20141015030631.GA6778@localhost.localdomain>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com>
 <20141014.124657.128658692728989163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60783 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831AbaJODGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 23:06:37 -0400
Content-Disposition: inline
In-Reply-To: <20141014.124657.128658692728989163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2014 at 12:46:57PM -0400, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu,  9 Oct 2014 22:55:30 +0200
> 
> > Here are some SCTP fixes.
> > 
> > [ Note, immediate workaround would be to disable ASCONF (it
> >   is sysctl disabled by default). It is actually only used
> >   together with chunk authentication. ]
> 
> Series applied, thanks guys.
Why did you apply this Dave? There was ongoing discussion around it.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

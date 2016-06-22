From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb
 and vlan show
Date: Wed, 22 Jun 2016 11:10:47 -0700
Message-ID: <20160622111047.1523b06f@xeon-e3>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
	<20160622145344.GE2068@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
	anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33413 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbcFVSKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 14:10:34 -0400
Received: by mail-pf0-f176.google.com with SMTP id i123so19925844pfg.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 11:10:34 -0700 (PDT)
In-Reply-To: <20160622145344.GE2068@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jun 2016 16:53:44 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Wed, Jun 22, 2016 at 03:45:50PM CEST, roopa@cumulusnetworks.com wrote:
> >From: Roopa Prabhu <roopa@cumulusnetworks.com>
> >
> >This patch series adds json support for a few bridge show commands.
> >We plan to follow up with json support for additional commands soon.  
> 
> I'm just curious, what is you use case for this? Apps can use rtnetlink
> socket directly.

Try using netlink in perl or python, it is quite difficult.

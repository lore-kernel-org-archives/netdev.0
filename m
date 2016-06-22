From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb
 and vlan show
Date: Wed, 22 Jun 2016 22:00:55 +0200
Message-ID: <20160622200055.GA1977@nanopsycho.orion>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
 <20160622145344.GE2068@nanopsycho.orion>
 <20160622111047.1523b06f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
	anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33962 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbcFVUA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 16:00:58 -0400
Received: by mail-wm0-f66.google.com with SMTP id 187so4505400wmz.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 13:00:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160622111047.1523b06f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 22, 2016 at 08:10:47PM CEST, stephen@networkplumber.org wrote:
>On Wed, 22 Jun 2016 16:53:44 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Wed, Jun 22, 2016 at 03:45:50PM CEST, roopa@cumulusnetworks.com wrote:
>> >From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> >
>> >This patch series adds json support for a few bridge show commands.
>> >We plan to follow up with json support for additional commands soon.  
>> 
>> I'm just curious, what is you use case for this? Apps can use rtnetlink
>> socket directly.
>
>Try using netlink in perl or python, it is quite difficult.

pyroute2? Quite easy...

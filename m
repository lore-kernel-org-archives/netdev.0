From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] netlink: IFLA_PHYS_SWITCH_ID to
 IFLA_PHYS_PARENT_ID
Date: Mon, 8 Dec 2014 12:49:14 -0500
Message-ID: <20141208174914.GH797@gospo.home.greyhouse.net>
References: <1417802537-20020-1-git-send-email-gospo@cumulusnetworks.com>
 <1417802537-20020-2-git-send-email-gospo@cumulusnetworks.com>
 <20141208151714.GG1885@nanopsycho.brq.redhat.com>
 <20141208153747.GG797@gospo.home.greyhouse.net>
 <20141208164143.GI1885@nanopsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:34128 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbaLHRt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 12:49:27 -0500
Content-Disposition: inline
In-Reply-To: <20141208164143.GI1885@nanopsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 08, 2014 at 05:41:43PM +0100, Jiri Pirko wrote:
> Mon, Dec 08, 2014 at 04:37:47PM CET, gospo@cumulusnetworks.com wrote:
> >On Mon, Dec 08, 2014 at 04:17:14PM +0100, Jiri Pirko wrote:
> >> Fri, Dec 05, 2014 at 07:02:16PM CET, gospo@cumulusnetworks.com wrote:
> >> >There has been much discussion about proper nomenclature to use for this
> >> >and I would prefer parent rather than calling every forwarding element a
> >> >switch.
> >> 
> >> Andy, I must say I really do not like just plain "parent". It is really
> >> not clear what it means as it can mean 1000 things.
> >> 
> >> I know "switch" is not ideal but everytime anyone is talking about these
> >> kind of forwarding devices, they use word "switch" even if it is not
> >> accurate and everyone knows what they are talking about. Nobody uses
> >> "parent".
> >
> >Well of course they are not going to use it until it's committed.  ;-)
> 
> 
> Do you seriously expect people talking about "parents" instead of
"Parent device" -- absolutely

> "switches". I doubt that...
Agree to disagree, I guess! 

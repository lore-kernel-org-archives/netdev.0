From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/5] mlxsw: small driver update
Date: Fri, 8 Apr 2016 19:11:45 +0200
Message-ID: <20160408171145.GD1932@nanopsycho.orion>
References: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
 <20160408155155.GC1932@nanopsycho.orion>
 <20160408.130737.1379821883201014485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36375 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180AbcDHRLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 13:11:48 -0400
Received: by mail-wm0-f67.google.com with SMTP id l6so5800622wml.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 10:11:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160408.130737.1379821883201014485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 08, 2016 at 07:07:37PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 8 Apr 2016 17:51:55 +0200
>
>> Fri, Apr 08, 2016 at 05:45:20PM CEST, jiri@resnulli.us wrote:
>>>From: Jiri Pirko <jiri@mellanox.com>
>>>
>>>Cosmetics, in preparation to sharedbuffer patchset.
>> 
>> Dave, I just realized there is dependency on:
>> "devlink: remove implicit type set in port register" which I sent couple
>> of minutes after this patchset. I can either resend in bulk, or if you
>> could apply in order, that would be great.
>
>The devlink series also lacked a header posting.  Can you just sort this
>all out properly and respin everything?

done.

>
>Thanks.
>
>> Thanks and sorry, owe you another beer :)
>
>:-)

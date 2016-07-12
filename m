From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Tue, 12 Jul 2016 08:44:48 +0200
Message-ID: <20160712064448.GA1884@nanopsycho.orion>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
 <20160711.134516.2253721322702070372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ivecera@redhat.com, rostedt@goodmis.org, mingo@redhat.com,
	jolsa@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33466 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280AbcGLGow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 02:44:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id o80so1084920wme.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 23:44:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160711.134516.2253721322702070372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 11, 2016 at 10:45:16PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 11 Jul 2016 15:18:47 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Define a tracepoint and allow user to trace messages going to and from
>> hardware associated with devlink instance.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>Jiri, I don't think "having a devlink_ prefix" is a strong enough argument
>for doing things specially here.
>
>Just use the tracing facilities and export them the way everyone else
>does, and the way that two people already have suggested.

ok

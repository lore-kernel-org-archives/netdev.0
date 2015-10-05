From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: HW communication debugging interface - ideas?
Date: Mon, 5 Oct 2015 11:56:33 +0200
Message-ID: <20151005095633.GE2278@nanopsycho.orion>
References: <20150930135141.GF2098@nanopsycho.orion>
 <9B0331B6EBBD0E4684FBFAEDA55776F91944E43E@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33545 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbbJEJ4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 05:56:35 -0400
Received: by wiclk2 with SMTP id lk2so111978439wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 02:56:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F91944E43E@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 05, 2015 at 11:54:38AM CEST, rami.rosen@intel.com wrote:
>Hi, Jiri,
>
>>In our case, we put message into skb and  ...
>
>Just to be sure we are on the same page:
>
>By "In our case" - I assume you are referring to the mlxsw Ethernet switch driver, right ? 

Yes.

>
>>we put message into skb and push that out as an ordinary packet. >HW then > sends us reply in a packet, similar to other rx-ed packets.
>
>Are you referring here to messages of the EMAD protocol ?

Yes.

>
>Rami Rosen
>Intel Corporation
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Thu, 22 Jan 2015 16:25:18 +0100
Message-ID: <20150122152518.GB1863@nanopsycho.orion>
References: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
 <9B0331B6EBBD0E4684FBFAEDA55776F918903CD5@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:46519 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbbAVPZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:25:22 -0500
Received: by mail-wg0-f41.google.com with SMTP id a1so2400852wgh.0
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:25:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F918903CD5@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 22, 2015 at 02:48:29PM CET, rami.rosen@intel.com wrote:
>+config NET_CLS_OPENFLOW
>+	tristate "OpenFlow classifier"
>+	select NET_CLS
>+	---help---
>+	  If you say Y here, you will be able to classify packets based on
>+	  a configurable combination of packet keys and masks accordint to
>+	  OpenFlow standard.
>+
>
>Should be: according to

I fixed this in my git. Thanks!

>
>Regards,
>Rami Rosen
>

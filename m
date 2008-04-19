From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Fri, 18 Apr 2008 21:34:39 -0400
Message-ID: <1208568879.4450.49.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>
	 <1208465951.15888.33.camel@localhost> <20080417140837.1e92b449@extreme>
	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>
	 <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost>
	 <20080418175941.2ae6506f@extreme>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:8415 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbYDSBeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 21:34:44 -0400
Received: by an-out-0708.google.com with SMTP id d31so213212and.103
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 18:34:43 -0700 (PDT)
In-Reply-To: <20080418175941.2ae6506f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-18-04 at 17:59 -0700, Stephen Hemminger wrote:


> If somebody doesn't do it first, maybe split the u32 output into:
> 	(nothing) original format
> 	-raw	  value/offset
> 	-pretty	  decoded equivalent of original command

If there is an agreement to make the original output default i.e use
-cooked if you want to prettify, else old output - then i will do it.
i.e i can work on top of the patch i sent.

cheers,
jamal


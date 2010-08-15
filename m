From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Patch-o-match
Date: Sun, 15 Aug 2010 12:14:39 -0600
Message-ID: <4C682E8F.8040600@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:58044 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750761Ab0HOSdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 14:33:05 -0400
Received: from macbook.redfish-solutions.com (macbook.redfish-solutions.com [192.168.1.17])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id o7FIEdcw015086
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 15 Aug 2010 12:14:39 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hi.

I'd like to build our astlinux images (it's an automated build) with the geoip and TARPIT patches, but can't seem to figure out how.

The links from the Netfilter extensions HowTo seemed to be broken... and since I'm statically building images, I figure that just figuring out the appropriate patches and downloading them by once is probably easier than getting patch-o-matic installed and scripted...  How do I go about doing that?

Oh, maybe also the ROUTE target.  Seemed that it and --tee would be useful for implementing an FBI Jack for lawful intercept in our PBX.

I know how to intercept a particular SIP session, but not the associated SDP (RTP) session that goes with it.  Is there an easy way to do that as well?

Thanks.

-Philip


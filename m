From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] netlink: support setting devgroup parameters
Date: Tue, 11 Jan 2011 07:40:51 -0500
Message-ID: <1294749651.3157.4.camel@mojatatu>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
	 <1294659524-22509-4-git-send-email-ddvlad@rosedu.org>
	 <1294665273.6063.292.camel@mojatatu>  <20110111121350.GB26417@cormyr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:48112 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700Ab1AKMkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 07:40:55 -0500
Received: by gyb11 with SMTP id 11so7716781gyb.19
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 04:40:54 -0800 (PST)
In-Reply-To: <20110111121350.GB26417@cormyr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-11 at 14:13 +0200, Vlad Dogaru wrote:

> 
> That sounds like a good idea, but, by using the same attribute,
> userspace won't be able to change the group of all the interfaces in a
> group, i.e. no more
> 	ip l set group 1 devgroup 0
> 
> However, I'm not sure that the use case above would be very common.

I think for the simple case we have been discussing this goes beyond
that. So maybe to KISS defer this to a later time.

cheers,
jamal


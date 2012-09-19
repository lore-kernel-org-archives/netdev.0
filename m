From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Netfilter lacks ability to filter packets via Application-origin
Date: Wed, 19 Sep 2012 21:24:12 +0100
Message-ID: <1348086252.2636.58.camel@bwh-desktop.uk.solarflarecom.com>
References: <COL002-W12C33BCBEB56AC8ADFF6B0F39B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chad Gray <chad938@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11958 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751692Ab2ISUYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:24:15 -0400
In-Reply-To: <COL002-W12C33BCBEB56AC8ADFF6B0F39B0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 15:40 -0400, Chad Gray wrote:
> Users need the ability for Linux firewall to filter packets based on what
> Application they are originating from. This ability is present in Mac and
> Windows firewalls, but not Linux.
> 
> For example, users would like ability to open Port 80 for Firefox, but keep
> Port 80 closed for other applications.
> 
> This ability enhances Privacy & Security of the user but also helps to better
> inform the user about the comings and goings of internet traffic and what
> application/s are causing the traffic.

Most of the Linux Security Modules seem to support this sort of network
policy.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

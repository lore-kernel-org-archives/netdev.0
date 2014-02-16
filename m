From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [net-next 08/14] i40evf: store ring size in ring structs
Date: Sun, 16 Feb 2014 14:43:29 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1402161441170.23286@cisco.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com> <1392418688-23895-9-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-2.cisco.com ([72.163.197.26]:11010 "EHLO
	bgl-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbaBPJW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 04:22:27 -0500
In-Reply-To: <1392418688-23895-9-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 14 Feb 2014, Aaron Brown wrote:

> From: Mitch Williams <mitch.a.williams@intel.com>
>
> Also update copyrights.
[.]
>  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
> - * Copyright(c) 2013 Intel Corporation.
> + * Copyright(c) 2013 - 2014 Intel Corporation.

Since you have a separate patch for this (patch 09/14), may be you can
move this change to 09/14?

thanks
//govind

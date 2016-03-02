From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 3/3] tc: pedit: Fix retain value for ihl
 adjustments
Date: Wed, 2 Mar 2016 09:54:14 -0800
Message-ID: <20160302095414.45a928df@xeon-e3>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
	<499abfe479324d1e83289cd68b2a7641@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:9673 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756140AbcCBRyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 12:54:08 -0500
In-Reply-To: <499abfe479324d1e83289cd68b2a7641@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Mar 2016 11:20:31 +0000
Phil Sutter <phil@nwl.cc> wrote:

> +		res = parse_cmd(&argc, &argv, 1, TU32,0x0f,sel,tkey);
>  		goto done;
Please add whitespace after ,

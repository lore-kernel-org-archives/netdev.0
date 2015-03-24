From: Ronald van der Pol <Ronald.vanderPol@rvdp.org>
Subject: Re: [net-next 8/9] i40e/i40evf: Bump i40e/i40evf version
Date: Tue, 24 Mar 2015 18:43:23 +0100
Message-ID: <20150324174322.GA512@rvdp.org>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1425923742-4488-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud6.xs4all.net ([194.109.24.24]:46729 "EHLO
	lb1-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752284AbbCXRnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:43:31 -0400
Content-Disposition: inline
In-Reply-To: <1425923742-4488-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 09, 2015 at 10:55:41 -0700, Jeff Kirsher wrote:

> From: Catherine Sullivan <catherine.sullivan@intel.com>
> 
> Bump PF version to 1.2.37 and VF version to 1.2.25

I am running this driver on CentOS 7.0.1406:
[ 1077.043391] i40e: Intel(R) Ethernet Connection XL710 Network Driver - version 1.2.37
[ 1077.043393] i40e: Copyright (c) 2013 - 2015 Intel Corporation.
[ 1077.062831] i40e 0000:81:00.0: f4.33.31377 a1.2 n4.42 e1932

Does it support the Intel X4DACBL3 QSFP to 4x SFP breakout cable?
I get:
get phy abilities failed, aq_err -7, advertised speed settings may not be correct

	rvdp

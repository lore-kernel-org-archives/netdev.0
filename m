From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 7/9] sky2: skb recycling
Date: Thu, 18 Jun 2009 14:13:20 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0906181411470.6076@jbrandeb-desk1.amr.corp.intel.com>
References: <20090617173031.703636683@vyatta.com> <20090617173140.244124173@vyatta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40386 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbZFRVNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 17:13:22 -0400
In-Reply-To: <20090617173140.244124173@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 17 Jun 2009, Stephen Hemminger wrote:

> This patch implements skb recycling. It reclaims transmitted skb's
> for use in the receive ring.

Was sky2 able to show any gain in forwarding performance due to this 
patch?  Was it significant?  What kind of machine was used to test?

From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] Don't dump eeprom when bnx2x adapter is down
Date: Thu, 08 Jan 2009 17:40:10 +0200
Message-ID: <1231429210.11301.12.camel@lb-tlvb-eliezer>
References: <20090107223411.GA4585@plap>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Paul Larson" <pl@linux.vnet.ibm.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1207 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758067AbZAHPkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 10:40:45 -0500
In-Reply-To: <20090107223411.GA4585@plap>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-07 at 14:34 -0800, Paul Larson wrote:
> Don't dump eeprom when bnx2x adapter is down.  Running ethtool -e gave
> me an eeh in testing only when the adapter was down.
> 
> Signed-off-by: Paul Larson <pl@linux.vnet.ibm.com>

Thanks Paul,

This is indeed a required patch. I will send another one for the set
eeprom method as well.

Thanks,
Eilon



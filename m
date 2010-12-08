From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 8 Dec 2010 21:10:53 +0200
Message-ID: <1291835453.24019.13.camel@lb-tlvb-vladz>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
 <4C48BD1A.4060409@chelsio.com>
 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
 <1291825443.31064.193.camel@lb-tlvb-vladz>
 <1291828940.2560.17.camel@bwh-desktop>
 <1291833578.17102.69.camel@lb-tlvb-vladz>
 <1291834931.2560.42.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Dimitris Michailidis" <dm@chelsio.com>,
	"Peter Waskiewicz" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4352 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755390Ab0LHTLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 14:11:09 -0500
In-Reply-To: <1291834931.2560.42.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The implementation of the -U
> option could potentially be made to fallback to ETHTOOL_SRXCLSRLINS if
> vlan_tag and user_def are not specified.
> 

Having said that, don't u think that it could be more user friendly to
extend the ETHTOOL_SRXCLSRLINS interface to handle the lan_tag and
user_def and drop the n-tuple interface at all?

thanks,
vlad 



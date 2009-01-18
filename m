From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/34]bnx2x: Block nvram access when the device is
 inactive
Date: Sat, 17 Jan 2009 23:23:05 -0800 (PST)
Message-ID: <20090117.232305.205950085.davem@davemloft.net>
References: <1231951447.11301.148.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pl@linux.vnet.ibm.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33456
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758680AbZARHXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:23:04 -0500
In-Reply-To: <1231951447.11301.148.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:44:07 +0200

> Don't dump eeprom when bnx2x adapter is down.  Running ethtool -e causes an eeh
> without it when the device is down
> 
> Signed-off-by: Paul Larson <pl@linux.vnet.ibm.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.

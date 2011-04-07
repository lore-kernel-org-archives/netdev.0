From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [RFC net-next] qlge: use ethtool set_phys_id
Date: Thu, 7 Apr 2011 09:49:21 -0700
Message-ID: <20110407164921.GA23693@linux-ox1b.qlogic.org>
References: <20110406164750.11cfeef3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Driver <Linux-Driver@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:39969 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751861Ab1DGRaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 13:30:14 -0400
Content-Disposition: inline
In-Reply-To: <20110406164750.11cfeef3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2011 at 04:47:50PM -0700, Stephen Hemminger wrote:
> This is a stab at replacing old ethtool phys_id with set_phys_id
> on the Qlogic 10Gb driver. Compile tested only.
> 
> Not sure if set_led_cfg will flash continuously, or needs
> to be replaced by ETHTOOL_ID_ON/ETHTOOL_ID_OFF
>

Stephen,
We are in the middle of a release cycle on another product.  We will
test this and get back to you next week.

Regards,
Ron Mercer

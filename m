From: David Miller <davem@davemloft.net>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Wed, 05 Jul 2006 11:22:37 -0700 (PDT)
Message-ID: <20060705.112237.41652489.davem@davemloft.net>
References: <1152033116.5276.22.camel@jzny2>
	<1152040839.5276.25.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	Robert.Olsson@data.slu.se, john.ronciak@intel.com,
	greearb@candelatech.com, auke-jan.h.kok@intel.com,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14798
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964963AbWGESWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 14:22:14 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152040839.5276.25.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 04 Jul 2006 15:20:39 -0400

> BTW, As an addendum this default behavior changed around 2.6.16 it
> seems.

Flow control has been on by default in the tg3 driver since the
beginning, maybe e1000 only recently started to behave that way
but it's the right thing to do IMHO.


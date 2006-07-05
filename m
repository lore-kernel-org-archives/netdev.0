From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Wed, 05 Jul 2006 11:32:08 -0700
Message-ID: <44AC05A8.9030503@intel.com>
References: <1152033116.5276.22.camel@jzny2>	<1152040839.5276.25.camel@jzny2> <20060705.112237.41652489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11140 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S964978AbWGESqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 14:46:24 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060705.112237.41652489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Tue, 04 Jul 2006 15:20:39 -0400
> 
>> BTW, As an addendum this default behavior changed around 2.6.16 it
>> seems.
> 
> Flow control has been on by default in the tg3 driver since the
> beginning, maybe e1000 only recently started to behave that way
> but it's the right thing to do IMHO.

As said earlier, e1000 always honors the EEPROM setting for this, which has 
been _on_ by default for all cards (AFAIK, that is).

Cheers,

Auke

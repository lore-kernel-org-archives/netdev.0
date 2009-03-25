From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 3/6] netfilter: limit the length of the helper name
Date: Wed, 25 Mar 2009 18:44:24 +0100
Message-ID: <49CA6D78.6000808@trash.net>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <20090316221138.326410717@jonathan.eitzenberger.org> <49CA6AAA.1050305@trash.net> <20090325174121.GB25526@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090325174121.GB25526@mail.eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Eitzenberger wrote:
> On Wed, Mar 25, 2009 at 06:32:26PM +0100, Patrick McHardy wrote:
> 
>> This appears to be an off-by-one. A strlen of exactly
>> NF_CT_HELPER_NAME_LEN - 1 would be fine, right?
>>
>> No need to resend, just let me know whether I should change it.
> 
> Yes please, feel free to change it :).

Done and applied, thanks.

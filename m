From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [RFC 1/2] ethtool: Add DMA Coalescing adapter feature to
 ethtool.
Date: Fri, 17 Jun 2011 07:54:00 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016EEF8967@orsmsx508.amr.corp.intel.com>
References: <1308071556-6271-1-git-send-email-carolyn.wyborny@intel.com>
 <20110616.233239.2238723246132860968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51367 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932392Ab1FQOyE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 10:54:04 -0400
In-Reply-To: <20110616.233239.2238723246132860968.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, June 16, 2011 8:33 PM
>To: Wyborny, Carolyn
>Cc: netdev@vger.kernel.org; bhutchings@solarflare.com
>Subject: Re: [RFC 1/2] ethtool: Add DMA Coalescing adapter feature to
>ethtool.
>
>From: Carolyn Wyborny <carolyn.wyborny@intel.com>
>Date: Tue, 14 Jun 2011 10:12:36 -0700
>
>> This RFC patch adds support for DMA Coalescing device feature
>> configuration via ethtool.
>>
>> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> ...
>>  static struct cmdline_info cmdline_offload[] = {
>> -	{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
>> -	{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
>> -	{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
>
>Can you please not destroy the existing formatting of every single
>table and piece of code you are modifying?

Yes, this is an error, I'm already redoing the patch.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



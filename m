From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
Date: Thu, 16 Jul 2009 13:07:26 -0700 (PDT)
Message-ID: <20090716.130726.220404456.davem@davemloft.net>
References: <AFAB8585072C7E48BC5C6F9C87F9B79703BA839300@pdsmsx502.ccr.corp.intel.com>
	<1ba2fa240907160804g18b1a215w3161c9682db7b35@mail.gmail.com>
	<1247763454.4549.56.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw@gmail.com, yi.zhu@intel.com, drzeus-list@drzeus.cx,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: marcel@holtmann.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933247AbZGPUHY@vger.kernel.org>
In-Reply-To: <1247763454.4549.56.camel@violet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 16 Jul 2009 18:57:34 +0200

> Hi Dave,
> 
>> > > Subject: RE: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
>> >
>> > BTW, subject should be "iwmc3200".
>> 
>> Thanks. I'll address all comments although I'm not sure how to split
>> the patch since adding SDIO_VENDOR_ID_INTEL to sdio_ids.h it affects
>> all the drivers anyhow, so I'm suggesting to route it through netdev.
> 
> I think it is best that you take the whole patch via net-next-2.6 to
> avoid breakage during the next merge window.

Fair enough.

From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
Date: Thu, 16 Jul 2009 18:57:34 +0200
Message-ID: <1247763454.4549.56.camel@violet>
References: <1247522953-12702-1-git-send-email-tomas.winkler@intel.com>
	 <AFAB8585072C7E48BC5C6F9C87F9B79703BA8388BB@pdsmsx502.ccr.corp.intel.com>
	 <AFAB8585072C7E48BC5C6F9C87F9B79703BA839300@pdsmsx502.ccr.corp.intel.com>
	 <1ba2fa240907160804g18b1a215w3161c9682db7b35@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Zhu, Yi" <yi.zhu@intel.com>,
	"drzeus-list@drzeus.cx" <drzeus-list@drzeus.cx>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55258 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbZGPQ5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 12:57:49 -0400
In-Reply-To: <1ba2fa240907160804g18b1a215w3161c9682db7b35@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > > Subject: RE: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
> >
> > BTW, subject should be "iwmc3200".
> 
> Thanks. I'll address all comments although I'm not sure how to split
> the patch since adding SDIO_VENDOR_ID_INTEL to sdio_ids.h it affects
> all the drivers anyhow, so I'm suggesting to route it through netdev.

I think it is best that you take the whole patch via net-next-2.6 to
avoid breakage during the next merge window.

Regards

Marcel



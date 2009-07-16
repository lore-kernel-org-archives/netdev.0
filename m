From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
Date: Thu, 16 Jul 2009 18:04:04 +0300
Message-ID: <1ba2fa240907160804g18b1a215w3161c9682db7b35@mail.gmail.com>
References: <1247522953-12702-1-git-send-email-tomas.winkler@intel.com>
	 <AFAB8585072C7E48BC5C6F9C87F9B79703BA8388BB@pdsmsx502.ccr.corp.intel.com>
	 <AFAB8585072C7E48BC5C6F9C87F9B79703BA839300@pdsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "drzeus-list@drzeus.cx" <drzeus-list@drzeus.cx>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757618AbZGPPEK@vger.kernel.org>
In-Reply-To: <AFAB8585072C7E48BC5C6F9C87F9B79703BA839300@pdsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2009 at 3:23 PM, Zhu, Yi <yi.zhu@intel.com> wrote:
>
> > Subject: RE: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
>
> BTW, subject should be "iwmc3200".

Thanks. I'll address all comments although I'm not sure how to split
the patch since adding SDIO_VENDOR_ID_INTEL to sdio_ids.h it affects
all the drivers anyhow, so I'm suggesting to route it through netdev.

Thanks
Tomas

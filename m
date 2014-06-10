From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 10:19:38 -0700
Message-ID: <20140610101938.26221bf8@nehalam.linuxnetplumber.net>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	patches@linaro.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37745 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbaFJRTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 13:19:41 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so912110pad.20
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 10:19:41 -0700 (PDT)
In-Reply-To: <20140610010803.18695.88446.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014 09:08:03 +0800
Andy Green <andy.green@linaro.org> wrote:

> +#define OGMA_REG_TOP_STATUS			(0x80)
> +#define OGMA_REG_TOP_INTEN			(0x81)
> +#define OGMA_REG_TOP_INTEN_SET			(0x8d)
> +#define OGMA_REG_TOP_INTEN_CLR			(0x8e)

Minor nit, paren's not needed around simple constants.

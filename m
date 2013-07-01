From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] openvswitch: Add Kconfig dependency on GRE-DEMUX.
Date: Mon, 01 Jul 2013 13:20:05 -0700 (PDT)
Message-ID: <20130701.132005.2228148168882336414.davem@davemloft.net>
References: <1372460860-19052-1-git-send-email-pshelar@nicira.com>
	<CAEP_g=_k9VCPwANhRc+T3xOboECVWZQs1SEtUaz0YfFtFiS71Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org,
	rdunlap@infradead.org, bhutchings@solarflare.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491Ab3GAUUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:20:06 -0400
In-Reply-To: <CAEP_g=_k9VCPwANhRc+T3xOboECVWZQs1SEtUaz0YfFtFiS71Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 28 Jun 2013 18:22:38 -0700

> On Fri, Jun 28, 2013 at 4:07 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Openvswitch uses function from NET_IPGRE_DEMUX module.
>> Add Kconfig dependency to fix following compilation errors:
>> http://marc.info/?l=linux-netdev&m=137244035226634
>>
>> CC: Jesse Gross <jesse@nicira.com>
>> Reported-by: Randy Dunlap <rdunlap@infradead.org>
>> Signed-off-by: Pravin Shelar <pshelar@nicira.com>
> 
> Acked-by: Jesse Gross <jesse@nicira.com>

Applied to net-next, thanks.

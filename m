From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH] Add Qualcomm Gobi 2000 driver.
Date: Fri, 01 Oct 2010 16:37:17 +0300
Message-ID: <4CA5E40D.4080507@gmail.com>
References: <20100928171026.GB6083@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darkstar.wilibox.com ([195.14.175.138]:53156 "EHLO
	darkstar.wilibox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274Ab0JANhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 09:37:21 -0400
In-Reply-To: <20100928171026.GB6083@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2010 08:10 PM, Elly Jones wrote:
> From: Elizabeth Jones<ellyjones@google.com>
>
> This driver is a rewrite of the original Qualcomm GPL driver, released as part
> of Qualcomm's "Code Aurora" initiative. The driver has been transformed into
> Linux kernel style and made to use kernel APIs where appropriate; some bugs have
> also been fixed. Note that the device in question requires firmware and a
> firmware loader; the latter has been written by mjg (see
> http://www.codon.org.uk/~mjg59/gobi_loader/).

Why not use already existing in kernel firmware upload API?

> Signed-Off-By: Elizabeth Jones<ellyjones@google.com>
> Signed-Off-By: Jason Glasgow<jglasgow@google.com>

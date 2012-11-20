From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] caif: Remove redundant null check before kfree in
 cfctrl.c
Date: Tue, 20 Nov 2012 15:53:25 -0500 (EST)
Message-ID: <20121120.155325.2219030136886421819.davem@davemloft.net>
References: <1353408838-28678-1-git-send-email-sachin.kamat@linaro.org>
	<81C3A93C17462B4BBD7E272753C105792457273283@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sachin.kamat@linaro.org, netdev@vger.kernel.org, patches@linaro.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab2KTUx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 15:53:26 -0500
In-Reply-To: <81C3A93C17462B4BBD7E272753C105792457273283@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Date: Tue, 20 Nov 2012 12:04:23 +0100

>> kfree on a null pointer is a no-op.
>>=20
>> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.

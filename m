From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH 1/1] caif: Remove redundant null check before kfree in
 cfctrl.c
Date: Tue, 20 Nov 2012 12:04:23 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105792457273283@EXDCVYMBSTM005.EQ1STM.local>
References: <1353408838-28678-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"patches@linaro.org" <patches@linaro.org>
To: Sachin Kamat <sachin.kamat@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:60844 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750953Ab2KTLEi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2012 06:04:38 -0500
In-Reply-To: <1353408838-28678-1-git-send-email-sachin.kamat@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> kfree on a null pointer is a no-op.
>=20
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

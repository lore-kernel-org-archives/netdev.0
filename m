From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH -next] caif_virtio: fix error return code in
 cfv_create_genpool()
Date: Fri, 22 Mar 2013 15:02:07 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C10579249583EE07@EXDCVYMBSTM005.EQ1STM.local>
References: <CAPgLHd-VdCq3qfDGYpCE1VmPeHGFneyR3TaarS=bMROqWmj2uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:53021 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933406Ab3CVO0K convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 10:26:10 -0400
In-Reply-To: <CAPgLHd-VdCq3qfDGYpCE1VmPeHGFneyR3TaarS=bMROqWmj2uA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Yes, this looks good to me,
Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

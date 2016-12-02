From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [net-next 1/5] qede: use reset to set network header
Date: Fri, 2 Dec 2016 07:35:07 +0000
Message-ID: <BL2PR07MB230684124F50BA6473B21BCB8D8E0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>,<1480643467-4420-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0058.outbound.protection.outlook.com ([104.47.34.58]:9974
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753936AbcLBHfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 02:35:09 -0500
In-Reply-To: <1480643467-4420-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Since offset is zero, it's not necessary to use set function. Reset
> function is straightforward, and will remove the unnecessary add
> operation in set function.

Thanks.

Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>

[For #2 for bnx2x as well]  =

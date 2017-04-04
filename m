From: "Tayar, Tomer" <Tomer.Tayar@cavium.com>
Subject: RE: [PATCH -next] qed: Add a missing error code
Date: Tue, 4 Apr 2017 06:13:04 +0000
Message-ID: <SN2PR07MB2623C0A41E3F1786DC08CC71800B0@SN2PR07MB2623.namprd07.prod.outlook.com>
References: <20170403182522.GA32592@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0067.outbound.protection.outlook.com ([104.47.34.67]:6022
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751005AbdDDGNI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 02:13:08 -0400
In-Reply-To: <20170403182522.GA32592@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We should be returning -ENOMEM if qed_mcp_cmd_add_elem() fails.  The
> current code returns success.
>=20
> Fixes: 4ed1eea82a21 ("qed: Revise MFW command locking")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks

Acked-by: Tomer Tayar <Tomer.Tayar@cavium.com>

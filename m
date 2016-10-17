From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH] qed: Use list_move_tail instead of list_del/list_add_tail
Date: Mon, 17 Oct 2016 19:10:10 +0000
Message-ID: <BL2PR07MB23068E5DAD844D5FDF31E4518DD00@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1476717471-16261-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0049.outbound.protection.outlook.com ([104.47.41.49]:51533
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759001AbcJQTKN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 15:10:13 -0400
In-Reply-To: <1476717471-16261-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Using list_move_tail() instead of list_del() + list_add_tail().

> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Thanks.
Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>=

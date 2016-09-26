From: "Amrani, Ram" <Ram.Amrani@cavium.com>
Subject: RE: [RFC v3 00/11] QLogic RDMA Driver (qedr) RFC
Date: Mon, 26 Sep 2016 15:45:56 +0000
Message-ID: <SN1PR07MB22070DA963EE029137924C72F8CD0@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1474899407-12635-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "Kalderon, Michal" <Michal.Kalderon@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Borundia, Rajesh" <Rajesh.Borundia@cavium.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
        "dledford@redhat.com" <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0085.outbound.protection.outlook.com ([104.47.42.85]:3232
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965516AbcIZPp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 11:45:58 -0400
In-Reply-To: <1474899407-12635-1-git-send-email-Ram.Amrani@cavium.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The series adds on top of RFC v2:
> * fix licensing header to dual license
> * remove 'debug' module paramter and make use of pr_debug
> * relocation of qedr user API to include/rdma/uapi/
> * use the __u32/64 in uapi and include types.h
> * advance ABI version (since shifting to __u32/64 changed the ABI)
> * remove the check for all drivers that IB_ACCESS_MW_BIND isn't set
>   in ib_get_dma_mr. It will be sent in a dedicated patch.
> * misc.: fixed typos, removed redundant includes
>=20
> For RFC v2 visit http://marc.info/?l=3Dlinux-rdma&m=3D147436779328618&w=
=3D2

I see that the following e-mails were sent with "PATCH" in the subject rath=
er than "RFC v3".
This is a mistake. All e-mails are intended to be "RFC v3".
I don't think it should matter much for reading and reviewing purposes, but=
 don't hesitate if=20
you would like me to re-send with fixed headers.

Ram

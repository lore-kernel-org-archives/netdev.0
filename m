From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: remove cast around the kmalloc in
 bnx2x_prev_mark_path
Date: Mon, 30 Jul 2012 07:50:45 +0300
Message-ID: <1343623845.27035.23.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1343567963-12389-1-git-send-email-develkernel412222@gmail.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3005 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab2G3Eu5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 00:50:57 -0400
Received: from [10.185.6.73] (lb-tlvb-eilong.il.broadcom.com
 [10.185.6.73]) by mail-irva-13.broadcom.com (Postfix) with ESMTP id
 C5E629F9F5 for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 21:50:47
 -0700 (PDT)
In-Reply-To: <1343567963-12389-1-git-send-email-develkernel412222@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-29 at 19:04 +0545, Devendra Naga wrote:
> casting the void pointer is redundant (Documentation/CodingStyle)
>=20
> Signed-off-by: Devendra Naga <develkernel412222@gmail.com>

Thanks Devendra, obviously, I=E2=80=99m acking this patch. I=E2=80=99m =
not so sure if it
should go into net though, and net-next is closed right now  but this i=
s
up to Dave.

Acked-by: Eilon Greenstein <eilong@broadcom.com>

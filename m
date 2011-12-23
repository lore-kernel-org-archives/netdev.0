From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH 1/2] alx: Coalesce long formats
Date: Thu, 22 Dec 2011 20:26:33 -0800
Message-ID: <CAMXMK6snujDQYe69soY9hZuSORrv0OpSf6OKiYwNcd33xJaKeA@mail.gmail.com>
References: <b177a0ce5b62188ba37f1c243d9fe792375c5fa3.1324613334.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cloud Ren <cjren@qca.qualcomm.com>, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@frijolero.org>,
	ath9k-devel <ath9k-devel@qualcomm.com>,
	Xiong Huang <xiong@qca.qualcomm.com>,
	Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:59064 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab1LWE0z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 23:26:55 -0500
In-Reply-To: <b177a0ce5b62188ba37f1c243d9fe792375c5fa3.1324613334.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 22, 2011 at 8:16 PM, Joe Perches <joe@perches.com> wrote:
> format strings broken into multiple bits are harder to grep.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> =A0drivers/net/ethernet/atheros/alx/alc_cb.c =A0 | =A0 =A03 +-
> =A0drivers/net/ethernet/atheros/alx/alf_cb.c =A0 | =A0 =A03 +-
> =A0drivers/net/ethernet/atheros/alx/alx_main.c | =A0 54 ++++++++++---=
-------------
> =A03 files changed, 23 insertions(+), 37 deletions(-)

Acked-by: Chris Snook <chris.snook@gmail.com>

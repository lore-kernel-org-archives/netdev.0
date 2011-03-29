From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: Fix compilation warning in function
 br_stp_recalculate_bridge_id()
Date: Tue, 29 Mar 2011 11:10:38 -0700
Message-ID: <20110329111038.2928bef7@s6510>
References: <1301415604-3871-1-git-send-email-balajig81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: "G.Balaji" <balajig81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43858 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459Ab1C2SKk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 14:10:40 -0400
In-Reply-To: <1301415604-3871-1-git-send-email-balajig81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Mar 2011 21:50:04 +0530
"G.Balaji" <balajig81@gmail.com> wrote:

> net/bridge/br_stp_if.c: In function =E2=80=98br_stp_recalculate_bridg=
e_id=E2=80=99:
> net/bridge/br_stp_if.c:216:3: warning: =E2=80=98return=E2=80=99 with =
no value, in function returning non-void
>=20
> Signed-off-by: G.Balaji <balajig81@gmail.com>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

(Forget to refresh quilt patch before sending).

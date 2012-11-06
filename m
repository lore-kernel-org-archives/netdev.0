From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net: ipv6: change %8s to %s for seq_printf of if6_seq_stop
Date: Tue, 06 Nov 2012 11:04:46 +0800
Message-ID: <50987E4E.7010404@asianux.com>
References: <5097A030.5030209@asianux.com> <509863D8.9020501@asianux.com> <50986AF6.10904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:42030 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933631Ab2KFDDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 22:03:45 -0500
In-Reply-To: <50986AF6.10904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA11=D4=C206=C8=D5 09:42, Shan Wei =D0=B4=B5=C0:
>=20
> trivial patches, send them in one patch for net/ subsystem.
>=20

1) Lucky !

  A) this time, I truly find another one for "* %8s to %s".
  B) in arch/x86/kernel/process_64.c (task->comm, TASK_COMM_LEN is 16).
  C) It seems that it is not suitable to send it to net subsystem.


2) Next:

  A) I shall send it to relative members according to MAINTAINERS.


3) Suggestions:

  welcome any members to giving additional suggestions and completions.


  thanks.

--=20
Chen Gang

Asianux Corporation

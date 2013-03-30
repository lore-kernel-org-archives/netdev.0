From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] include/linux: printk is needed in filter.h when CONFIG_BPF_JIT
 is defined
Date: Sat, 30 Mar 2013 11:17:17 +0800
Message-ID: <5156593D.3000503@asianux.com>
References: <5153DC24.4010104@asianux.com> <5154ED65.5090607@asianux.com> <20130329.153447.426374969178935845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, dborkman@redhat.com, wad@chromium.org,
	eparis@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:29194 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757653Ab3C3DRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 23:17:48 -0400
In-Reply-To: <20130329.153447.426374969178935845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B403=E6=9C=8830=E6=97=A5 03:34, David Miller wrote:
> I think the issue is more like that the ARM bpf jit code uses
> those routines, and therefore the ARM bpf jit code is what needs
> to add these includes.

  for arm, I should continue to try to find new valuable issues.

  :-)


--=20
Chen Gang

Asianux Corporation

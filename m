From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v8 3/3] geneve: add IPv6 bits to geneve_fill_metadata_dst
Date: Tue, 27 Oct 2015 22:24:34 +0800
Message-ID: <CAEP_g=9CPe+gEs7T=nSLJUDBJwMcihJP5PXD=KsrEOOH5pRx3g@mail.gmail.com>
References: <1445893306-31225-3-git-send-email-linville@tuxdriver.com> <1445953740-14810-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36659 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932306AbbJ0OYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:24:54 -0400
Received: by ykba4 with SMTP id a4so213601290ykb.3
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 07:24:53 -0700 (PDT)
In-Reply-To: <1445953740-14810-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 9:49 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> v7 -- initial version (numbered to match earlier patches in series)
> v8 -- fixup of bracing on an "else { return -EINVAL; }"

Reviewed-by: Jesse Gross <jesse@nicira.com>

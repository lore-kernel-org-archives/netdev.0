From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 0/2] libbpf: minor fix and API update
Date: Mon, 15 Aug 2016 09:22:58 +0800
Message-ID: <57B11972.6040307@huawei.com>
References: <1471090643-22403-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:50828 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcHOBXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 21:23:34 -0400
In-Reply-To: <1471090643-22403-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think you should cc linux-kernel@vger.kernel.org for code in
tools/ .

Thank you.

On 2016/8/13 20:17, Eric Leblond wrote:
> Hello,
>
> Here's a small patchset on libbpf fixing two issues I've encountered
> when adding some eBPF related features to Suricata.
>
> Patchset statistics:
>   tools/lib/bpf/libbpf.c | 16 +++++++---------
>   tools/lib/bpf/libbpf.h |  4 +++-
>   2 files changed, 10 insertions(+), 10 deletions(-)
>
> BR,
> --
> Eric Leblond

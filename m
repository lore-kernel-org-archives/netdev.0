From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next] bpf: minor fix in api and
 bpf_dump_error() usage
Date: Thu, 17 Dec 2015 17:23:06 -0800
Message-ID: <20151217172306.17bdb569@xeon-e3>
References: <6598a3bfadced14239ea333155eb7fb9aaceccda.1450108152.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34003 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbbLRBW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 20:22:59 -0500
Received: by mail-pf0-f175.google.com with SMTP id 68so39768864pfc.1
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 17:22:59 -0800 (PST)
In-Reply-To: <6598a3bfadced14239ea333155eb7fb9aaceccda.1450108152.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Dec 2015 16:57:32 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Fix a whitespace in bpf_dump_error() usage, and also a missing closing
> bracket in ntohl() macro for eBPF programs.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---

Applied to net-next

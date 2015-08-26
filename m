From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/5] net_sched: make tcf_hash_destroy() static
Date: Wed, 26 Aug 2015 10:05:16 +0200
Message-ID: <55DD733C.9080707@iogearbox.net>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com> <1440558395-7765-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53365 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbbHZIFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 04:05:21 -0400
In-Reply-To: <1440558395-7765-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 05:06 AM, Alexei Starovoitov wrote:
> tcf_hash_destroy() used once. Make it static.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Fri, 01 May 2015 14:46:08 +0200
Message-ID: <55437590.4090404@iogearbox.net>
References: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40601 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbEAMqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 08:46:12 -0400
In-Reply-To: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2015 05:11 AM, Alexei Starovoitov wrote:
> improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net-next 1/2] net: introduce skb_postpush_rcsum() helper
Date: Sat, 11 Apr 2015 08:40:41 +0200
Message-ID: <5528C1E9.8050900@iogearbox.net>
References: <1428708792-5872-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, Thomas Graf <tgraf@suug.ch>,
	Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46414 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbbDKGlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 02:41:00 -0400
In-Reply-To: <1428708792-5872-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2015 01:33 AM, Alexei Starovoitov wrote:
> similar to skb_postpull_rcsum() introduce skb_postpush_rcsum() helper
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

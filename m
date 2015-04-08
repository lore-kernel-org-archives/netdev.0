From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/2] net: introduce skb_postpush_rcsum() helper
Date: Wed, 08 Apr 2015 09:25:59 +0200
Message-ID: <5524D807.6010609@iogearbox.net>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59774 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbDHH0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 03:26:08 -0400
In-Reply-To: <1428455025-5945-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 03:03 AM, Alexei Starovoitov wrote:
> similar to skb_postpull_rcsum() introduce skb_postpush_rcsum() helper
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

This one you could resend nevertheless as a stand-alone as it
also improves the existing parts.

Would be good if you could also add a proper kernel doc part
as in skb_postpull_rcsum().

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

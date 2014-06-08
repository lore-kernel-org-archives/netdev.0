From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: fix nlattr and nlattr_nest BPF
 tests
Date: Sun, 08 Jun 2014 22:07:21 +0200
Message-ID: <5394C279.9000405@redhat.com>
References: <1402102100-30215-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755988AbaFHUHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 16:07:31 -0400
In-Reply-To: <1402102100-30215-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2014 02:48 AM, Alexei Starovoitov wrote:
> - 'struct nlattr' must be 2 byte aligned
> - provide big-endian input data for nlattr/nlattr_nest tests
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

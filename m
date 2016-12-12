From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [iproute2 net-next 3/8] bpf: Add BPF_ macros
Date: Mon, 12 Dec 2016 12:28:12 +0100
Message-ID: <88e7eece-be2a-3b11-3dc1-3afa7a9bb14a@stressinduktion.org>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
 <1481503995-24825-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41273 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752035AbcLLL2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 06:28:16 -0500
In-Reply-To: <1481503995-24825-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.12.2016 01:53, David Ahern wrote:
> Based on version in kernel repo, samples/bpf/libbpf.h
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/bpf_util.h | 179 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 179 insertions(+)
> 
> diff --git a/include/bpf_util.h b/include/bpf_util.h
> index 726e34777755..5361dab1933d 100644

Maybe this was already discussed: why are those not part of uapi? They
get used in the bpf manpage.

Bye,
Hannes

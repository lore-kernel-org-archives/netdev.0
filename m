From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] packet: make packet too small warning match
 condition
Date: Thu, 08 Jan 2015 22:21:53 +0100
Message-ID: <54AEF4F1.108@redhat.com>
References: <1420734558-30979-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jkmalinen@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754646AbbAHVWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 16:22:02 -0500
In-Reply-To: <1420734558-30979-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 05:29 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> The expression in ll_header_truncated() tests less than or equal, but
> the warning prints less than. Update the warning.
>
> Reported-by: Jouni Malinen <jkmalinen@gmail.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

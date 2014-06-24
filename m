From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] trivial: net: filter: Change kerneldoc parameter order
Date: Tue, 24 Jun 2014 15:42:24 +0200
Message-ID: <53A98040.9030101@redhat.com>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch> <1403616802-25743-2-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029AbaFXNme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 09:42:34 -0400
In-Reply-To: <1403616802-25743-2-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2014 03:33 PM, Tobias Klauser wrote:
> Change the order of the parameters to sk_unattached_filter_create() in
> the kerneldoc to reflect the order they appear in the actual function.
>
> This fix is only cosmetic, in the generated doc they still appear in the
> correct order without the fix.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

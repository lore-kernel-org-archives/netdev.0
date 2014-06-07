From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/2] bridge fdb dumping takes a filter device
 Dumping a bridge fdb dumps every fdb entry held. With this change we are
 going to filter on selected bridge port.
Date: Sat, 07 Jun 2014 08:41:00 -0400
Message-ID: <5393085C.6030405@mojatatu.com>
References: <1401623780-4297-1-git-send-email-jhs@emojatatu.com> <20140605.001514.517987695784091540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33331 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbaFGMlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 08:41:21 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so1827307igd.8
        for <netdev@vger.kernel.org>; Sat, 07 Jun 2014 05:41:20 -0700 (PDT)
In-Reply-To: <20140605.001514.517987695784091540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/14 03:15, David Miller wrote:

>
> Jamal take it easy with the subject lines :-)
>

LOL.Cant think of anything clever to say to that.
Maybe you should just accept my attachments ;->

Anyways, I have to resend the patches to consider
the comments from Vlad.

cheers,
jamal

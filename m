From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next-2.6 PATCH v5 0/2] bridge: fdb dumping takes a filter
 device
Date: Thu, 10 Jul 2014 06:23:32 -0400
Message-ID: <53BE69A4.7010808@mojatatu.com>
References: <1404380290-17040-1-git-send-email-jhs@emojatatu.com>	<20140708.141038.712786607116212110.davem@davemloft.net> <20140708.142155.1915030425034037065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:62057 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbaGJKXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 06:23:47 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so140436ier.34
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 03:23:47 -0700 (PDT)
In-Reply-To: <20140708.142155.1915030425034037065.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/14 17:21, David Miller wrote:

>
> drivers/net/vxlan.c:2181:2: warning: initialization from incompatible=
 pointer type [enabled by default]
> drivers/net/vxlan.c:2181:2: warning: (near initialization for =A1vxla=
n_netdev_ops.ndo_fdb_dump=A2) [enabled by default]
>

Your patience knows no bounds ;->
I will send an update shortly.

cheers,
jamal

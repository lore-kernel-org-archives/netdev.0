From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net] bonding: Avoid possible de-sync with arp_validate
Date: Fri, 06 Sep 2013 15:02:55 -0300
Message-ID: <522A18CF.1030606@redhat.com>
References: <994d2dc994a801fc3aae7aa912266b09ea45d95c.1378489255.git.mleitner@redhat.com> <20130906.135836.365469022075105934.davem@davemloft.net>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, naleksan@redhat.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab3IFSDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 14:03:03 -0400
In-Reply-To: <20130906.135836.365469022075105934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 06-09-2013 14:58, David Miller escreveu:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Date: Fri,  6 Sep 2013 14:41:53 -0300
>
>> Please queue this one for -stable trees too.
>
> This is very much not the correct way to submit a patch.
>
> First of all, you haven't signed off on the patch.
>
> Second of all, any supplemental information that doesn't belong in the
> commit message needs to go after a "---" dileanator line.

Okay, sorry for that. I'll resubmit as soon as I work on Jay's comments.

Thanks
Marcelo

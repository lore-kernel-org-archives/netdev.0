From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 1/9] mlxsw: pci: Add resources query
 implementation.
Date: Thu, 21 Jul 2016 05:41:18 -0400
Message-ID: <a126bf4d-2347-6b67-6cc7-99184aca55b9@mojatatu.com>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
 <1469089160-4239-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33574 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbcGUJlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:41:22 -0400
Received: by mail-lf0-f50.google.com with SMTP id b199so56749569lfe.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 02:41:22 -0700 (PDT)
In-Reply-To: <1469089160-4239-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, here's an example:

On 16-07-21 04:19 AM, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
>
>
> +static int
> +mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
> +			  struct mlxsw_resources *resources, u8 query_enabled)
> +{

to:

static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char 
*mbox,
                                      struct mlxsw_resources *resources,
                                      u8 query_enabled)
{

Email is splitting that first line - but it is 80 chars or less

cheers,
jamal

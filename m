From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] bonding: remove the redundant judgements
 for bond_option_queue_id_set()
Date: Thu, 13 Feb 2014 15:30:09 +0100
Message-ID: <20140213143009.GB2829@minipsycho.orion>
References: <1392188330-17208-1-git-send-email-dingtianhong@huawei.com>
 <1392188330-17208-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:36773 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbaBMOaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 09:30:12 -0500
Received: by mail-ea0-f178.google.com with SMTP id a15so5108791eae.23
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 06:30:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1392188330-17208-3-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 12, 2014 at 07:58:50AM CET, dingtianhong@huawei.com wrote:
>The dev_valid_name() will check the buffer length for input name, no need to
>check it twice.
>
>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>

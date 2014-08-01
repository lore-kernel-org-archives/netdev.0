From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/2] random32: do not feed jiffies as seed from
 lpfc driver
Date: Fri, 01 Aug 2014 13:23:14 +0200
Message-ID: <53DB78A2.4090504@redhat.com>
References: <1406837317-13648-1-git-send-email-dborkman@redhat.com> <1406866378.5442.9.camel@jarvis>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"james.smart@emulex.com" <james.smart@emulex.com>
To: James Bottomley <jbottomley@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327AbaHALXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 07:23:24 -0400
In-Reply-To: <1406866378.5442.9.camel@jarvis>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 06:12 AM, James Bottomley wrote:
...
> Could you send to linux-scsi@vger.kernel.org; Christoph Hellwig is
> gathering patches for SCSI via that list.

Sure, done, thanks.

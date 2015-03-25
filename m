From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 7/7] net: bcmgenet: add support for multiple
 Rx queues
Date: Wed, 25 Mar 2015 15:29:45 -0700
Message-ID: <551336D9.7000907@gmail.com>
References: <20150325193516.417182201FC@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34671 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbbCYWa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:30:28 -0400
Received: by pdbni2 with SMTP id ni2so42229421pdb.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:30:27 -0700 (PDT)
In-Reply-To: <20150325193516.417182201FC@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 12:35, Petri Gynther wrote:
> Add support for multiple Rx queues:
> 1. Add NAPI context per Rx queue
> 2. Modify Rx interrupt and Rx NAPI code to handle multiple Rx queues
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian

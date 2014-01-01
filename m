From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] sched action: make local function static
Date: Wed, 01 Jan 2014 11:48:33 -0500
Message-ID: <52C446E1.2050706@mojatatu.com>
References: <20131231115400.6e85bd34@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:60451 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbaAAQsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 11:48:36 -0500
Received: by mail-ig0-f175.google.com with SMTP id j1so39990692iga.2
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 08:48:36 -0800 (PST)
In-Reply-To: <20131231115400.6e85bd34@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/13 14:54, Stephen Hemminger wrote:
> No need to export functions only used in one file.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal

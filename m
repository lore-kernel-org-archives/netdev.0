From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Kill hold_net release_net
Date: Wed, 11 Mar 2015 21:35:23 -0700
Message-ID: <1426134923.11398.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150311.215553.1544350193194225837.davem@davemloft.net>
	 <1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.232940.1345045254716776224.davem@davemloft.net>
	 <87oany7tha.fsf_-_@x220.int.ebiederm.org>
	 <87ioe67tfr.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	salo@google.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:36497 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbbCLEf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:35:28 -0400
Received: by iegc3 with SMTP id c3so16854407ieg.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 21:35:27 -0700 (PDT)
In-Reply-To: <87ioe67tfr.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 23:04 -0500, Eric W. Biederman wrote:
> hold_net and release_net were an idea that turned out to be useless.
> The code has been disabled since 2008.  Kill the code it is long past due.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

From: David Newall <davidn@davidnewall.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Sat, 26 Apr 2014 22:44:49 +0930
Message-ID: <535BB149.3090901@davidnewall.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, davem@davemloft.net, jpa@google.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:39465 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaDZNOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 09:14:54 -0400
In-Reply-To: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lorenzo,

> In some environments it is useful to route packets differently
> based on the user ID.

I don't understand what your patch will do because, as I understand the 
word, "routing" means forwarding a packet one hop closer to the 
destination, so I expect you must reach the destination before you could 
know the UID.  I'm probably missing something quite obvious. Could you 
illustrate a use-case?

Thanks,

David

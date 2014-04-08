From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: wake up all assocs if sndbuf policy
 is per socket
Date: Tue, 08 Apr 2014 18:57:06 +0200
Message-ID: <53442A62.3050905@redhat.com>
References: <1396970773-17500-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754579AbaDHQ5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 12:57:43 -0400
In-Reply-To: <1396970773-17500-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hm, I still found an issue, please hold on with this one, thanks.

From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: ipv6: mldv1/v2: fix switchback timeout
 to rfc3810, 9.12.
Date: Thu, 29 Aug 2013 23:24:57 +0200
Message-ID: <521FBC29.2090700@redhat.com>
References: <1377792578-32642-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755643Ab3H2VZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 17:25:07 -0400
In-Reply-To: <1377792578-32642-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, please hold on with this one. This is already better, but
it still needs to be improved slightly. Will send an update tomorrow
or at latest at the beginning of next week.

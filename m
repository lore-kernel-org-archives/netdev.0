From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: check for ndo_select_queue during queue selection
Date: Fri, 14 Feb 2014 22:03:06 +0100
Message-ID: <52FE848A.8000905@redhat.com>
References: <1392311935-10275-1-git-send-email-dborkman@redhat.com> <20140214.004048.616136663605863975.davem@davemloft.net> <52FDEE22.9010503@redhat.com> <20140214.134843.1912150240271947468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mathias.kretschmer@fokus.fraunhofer.de, netdev@vger.kernel.org,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972AbaBNVDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 16:03:14 -0500
In-Reply-To: <20140214.134843.1912150240271947468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the feedback Dave, will fix that up tomorrow.

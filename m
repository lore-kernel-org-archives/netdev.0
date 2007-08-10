From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24]S2io: Default to IntA interrupt type when there
 are	less than 4 CPUs in the system.
Date: Fri, 10 Aug 2007 13:38:56 -0400
Message-ID: <46BCA2B0.7020501@garzik.org>
References: <Pine.GSO.4.10.10708100059390.18391-100000@guinness> <46BC97E5.6020509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>,
	netdev@vger.kernel.org, support@neterion.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45822 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938839AbXHJRjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 13:39:00 -0400
In-Reply-To: <46BC97E5.6020509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Sivakumar Subramani wrote:
>> - Default to IntA interrupt type when there are less than 4 CPUs in 
>> the system.
> 
> It might be good to include _why_ in the comment(s).  I certainly am 
> curious to know the reason, and it would be good to have in there for 
> "posterity" should the underlying conditions change.

Indeed.  I really want to know 'why'?

	Jeff




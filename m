From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.24]S2io: Default to IntA interrupt type when there
 are	less than 4 CPUs in the system.
Date: Fri, 10 Aug 2007 09:52:53 -0700
Message-ID: <46BC97E5.6020509@hp.com>
References: <Pine.GSO.4.10.10708100059390.18391-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:47168 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933661AbXHJQxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 12:53:45 -0400
In-Reply-To: <Pine.GSO.4.10.10708100059390.18391-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sivakumar Subramani wrote:
> - Default to IntA interrupt type when there are less than 4 CPUs in the system.

It might be good to include _why_ in the comment(s).  I certainly am 
curious to know the reason, and it would be good to have in there for 
"posterity" should the underlying conditions change.

rick jones

From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [RFC] NAPI support for forcedeth
Date: Tue, 18 Jul 2006 20:41:18 +0100
Message-ID: <44BD395E.4070101@gentoo.org>
References: <20060717171847.30d08dfb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:58780 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932368AbWGRTef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 15:34:35 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060717171847.30d08dfb@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Stephen Hemminger wrote:
> Experimental version of NAPI for forcedeth.
> Untested, but others may want to help with comments and testing.

I tested this: it worked for about 2 minutes, then the connection 
dropped and I was unable to connect to anything.

I'll try and find some time to get you a more informative report.

Daniel


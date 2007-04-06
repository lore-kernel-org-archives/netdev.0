From: Ben Greear <greearb@candelatech.com>
Subject: Re: pci-e e1000 not responding to ARPs sometimes?
Date: Thu, 05 Apr 2007 22:46:44 -0700
Message-ID: <4615DEC4.4070107@candelatech.com>
References: <08FE5CC30C9A3F41BF819A502CF7BF6E010A654D@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39021 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbXDFFqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 01:46:49 -0400
In-Reply-To: <08FE5CC30C9A3F41BF819A502CF7BF6E010A654D@fmsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tantilov, Emil S wrote:
> Sorry for the top post.
>
> I believe this is a known issue and it was fixed in the kernel driver as
> well (maybe it didn't make it into FC5 kernel?). 
>
> See the following:
> http://article.gmane.org/gmane.linux.network/52168/match=e1000+factps+mn
> gcg
>   

Thank you!  I've added this patch and we will do some testing on it 
tomorrow.
I will let you know how it works out.

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



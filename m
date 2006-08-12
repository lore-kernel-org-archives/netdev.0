From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [PATCH 4/6] ehea: header files
Date: Sat, 12 Aug 2006 18:40:13 +0200
Message-ID: <44DE046D.2050304@de.ibm.com>
References: <44D99F56.7010201@de.ibm.com> <20060811220728.GI479@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:60761 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP id S964887AbWHLQkQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 12:40:16 -0400
To: Anton Blanchard <anton@samba.org>,
	Jan-Bernd Themann <themann@de.ibm.com>
In-Reply-To: <20060811220728.GI479@krispykreme>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
>> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea.h	1969-12-31 
>>     
>
>   
>> +extern void exit(int);
>>     
>
> Should be able to remove that prototype :) 
>
> Anton
>   
Indeed :-) It's gone.

Thomas


From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [REVISED] [PATCH] ethtool v4: add autoneg advertise feature
Date: Tue, 19 Sep 2006 15:04:47 -0400
Message-ID: <45103F4F.6030602@pobox.com>
References: <20060905151016.8244.16888.stgit@jtkirshe-sled.jf.intel.com> <9929d2390609061119g344bd484tca0ef2ada6c5eb34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:21946 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751023AbWISTEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:04:52 -0400
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <9929d2390609061119g344bd484tca0ef2ada6c5eb34@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher wrote:
> On 9/5/06, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>>
>> adds the ability to change the advertised speed and duplex for a 
>> network interface.  Previously, a network interface was only able to 
>> advertise all supported speed's and duplex's, or one individual speed 
>> and duplex.  The feature allows the user to choose which supported 
>> speed's and duplex's to advertise by using the hex value.
>>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>
>> ---
> 
> This patch can be pull from the following location:
> 
> git pull git://lost.foo-projects.org/~jtkirshe/ethtool e1000

pulled



From: Valentina Giusti <valentina.giusti@bmw-carit.de>
Subject: Re: [PATCH v4 1/2] netfilter_queue: enable UID/GID socket info retrieval
Date: Tue, 7 Jan 2014 09:11:50 +0100
Message-ID: <52CBB6C6.7020404@bmw-carit.de>
References: <1387556934-7372-1-git-send-email-valentina.giusti@bmw-carit.de> <1387556934-7372-2-git-send-email-valentina.giusti@bmw-carit.de> <20131223142118.GA4803@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jpa@google.com>, <fw@strnel.de>, <daniel.wagner@bmw-carit.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131223142118.GA4803@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2013 03:21 PM, Pablo Neira Ayuso wrote:
> On Fri, Dec 20, 2013 at 05:28:53PM +0100, valentina.giusti@bmw-carit.de wrote:
>> From: Valentina Giusti <valentina.giusti@bmw-carit.de>
>>
>> Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 (udp: ipv4:
>> Add udp early demux) it is now possible to parse UID and GID socket info
>> also for incoming TCP and UDP connections. Having this info available, it
>> is convenient to let NFQUEUE parse it in order to improve and refine the
>> traffic analysis in userspace.
>
> Applied the kernel patch, wait for a new patch for libnetfilter_queue. Thanks.
>

Hi Pablo,

thanks for applying the kernel patch and also for the comments on the 
userspace patch, I'll send a new patch that addresses them ASAP.
Sorry for the delay, I was away during the past 2 weeks.

BR,
- Val


From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/6] iptables: read/write lock elimination (v0.4)
Date: Thu, 29 Jan 2009 15:39:13 -0800
Message-ID: <49823E21.1050608@hp.com>
References: <20090129191239.483204605@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090129191239.483204605@vyatta.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This is an update to last round of patches, using Eric's suggestion
> to move the sequence count to top level per cpu variable. Also encapsulated
> the counter manipulation.

Is this version one you would like me to toss into the crucible of the 32-core 
setup, or do you want it to have more eyeball time first?

rick jones

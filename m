From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 18:06:17 -0400
Message-ID: <482B6259.3070507@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <482B378C.5070807@garzik.org> <20080514193843.GB10165@2ka.mipt.ru> <20080514215704.GE23758@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jamie Lokier <jamie@shareable.org>,
	Sage Weil <sage@newdream.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080514215704.GE23758@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamie Lokier wrote:
> With the right topology and hardware, you can get _faster_ than single
> node performance with as many nodes as you like

This is the core reason why I am so interested in distributed storage... 
  a single storage device is usually slower than network wire speed. 
Multiple nodes helps remove that limitation and max out the network.

I want to be able to stream data _faster_ than a single hard drive can 
handle :)

	Jeff




From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Cache coherency,
 transactions, parallels.
Date: Sun, 25 May 2008 15:55:00 -0400
Message-ID: <4839C414.3070504@garzik.org>
References: <20080525134055.GA30630@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080525134055.GA30630@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>  * Client parallel extensions: ability to write to multiple servers and
> 	balance reading between them. Code was imported to the current version,
> 	but not enabled yet.
>  * Client dynamical server reconfiguration: ability to add/remove servers
> 	from working set by server command and from userspace.

Neat :)


> 2. Source archive.
> http://tservice.net.ru/~s0mbre/archive/pohmelfs/
> Git tree.
> http://tservice.net.ru/~s0mbre/archive/pohmelfs/pohmelfs.git/

Is the server available via git?

http://tservice.net.ru/~s0mbre/archive/pohmelfs/server/ does not include 
history information, etc.

	Jeff



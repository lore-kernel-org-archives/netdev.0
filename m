From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Cache coherency,
 transactions, parallels.
Date: Mon, 26 May 2008 02:33:59 -0400
Message-ID: <483A59D7.7020306@garzik.org>
References: <20080525134055.GA30630@2ka.mipt.ru> <483A0F3B.9060709@garzik.org> <20080526062204.GA16366@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080526062204.GA16366@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Sun, May 25, 2008 at 09:15:39PM -0400, Jeff Garzik (jeff@garzik.org) wrote:
>> Evgeniy Polyakov wrote:
>>> Git tree.
>>> http://tservice.net.ru/~s0mbre/archive/pohmelfs/pohmelfs.git/
>> Is this really the latest commit?
>>
>> commit 21549d0a101c1c9dcdb1fe8d59685415cc0a5e9a
>> Author: Evgeniy Polyakov johnpol@2ka.mipt.ru <zbr@gavana.yandex.ru>
>> Date:   Tue May 13 20:54:49 2008 +0400
>>
>> I would have guessed modifications occurred more recently than May 13.
> 
> No it should be cc4d281eb8d9a4d3a5610acf1558c327358f5725
> Author: Evgeniy Polyakov johnpol@2ka.mipt.ru <zbr@gavana.yandex.ru>
> Date:   Sun May 25 17:24:56 2008 +0400
> 
>     Kconfig entries for cc group and debugging.
>     
> I used 'git push remote_repo' to push data after repository was create, probably I
> should use 'git push --all remote_repo', please try again.

Nope.

Did you forget git-update-server-info, since your method is HTTP?

	Jeff




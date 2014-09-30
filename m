From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: 3.17-rc1 oops during network interface configuration
Date: Tue, 30 Sep 2014 10:56:35 -0400
Message-ID: <D9F26997-DF54-467F-8CB4-22D840157660@oracle.com>
References: <53F1EF18.7010909@acm.org> <53F47917.8080003@mellanox.com> <F580F466-28A5-4BDD-A338-D5C065A760C1@oracle.com> <541000F1.5000805@mellanox.com> <6C43129E-4365-4BEF-ADAD-963B8F386789@oracle.com> <1412017217.30721.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bart Van Assche <bvanassche@acm.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Roland Dreier <roland@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412017217.30721.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 29, 2014, at 3:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2014-09-29 at 14:52 -0400, Chuck Lever wrote:
> 
>> Is there a bugzilla report filed for this issue? Has there been any progress
>> towards a fix?
> 
> This is fixed in Linus tree.
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=257117862634d89de33fec74858b1a0ba5ab444b
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=b49fe36208b45f76dfbcfcd3afd952a33fa9f5ce

Tested 3.17-rc7, fix confirmed. Many thanks, Eric!

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

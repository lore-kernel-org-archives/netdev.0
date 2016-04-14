From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/6] bridge: support sending rntl
 info when we set attributes through sysfs/ioctl
Date: Wed, 13 Apr 2016 22:42:51 -0400 (EDT)
Message-ID: <20160413.224251.128814102171837505.davem@davemloft.net>
References: <cover.1460131308.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	nikolay@cumulusnetworks.com
To: lucien.xin@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1460131308.git.lucien.xin@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  9 Apr 2016 00:03:27 +0800

> This patchset is used to support sending rntl info to user in some places,
> and ensure that whenever those attributes change internally or from sysfs,
> that a netlink notification is sent out to listeners.
> 
> It also make some adjustment in bridge sysfs so that we can implement this
> easily.
> 
> I've done some tests on this patchset, like:
 ...
> This test covers all the attributes that brctl and sysfs support to set.

Series applied, thanks.

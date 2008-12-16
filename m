From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 12/29] i2400m: host/device procotol and core driver
	definitions
Date: Tue, 16 Dec 2008 11:43:45 +0800
Message-ID: <494723F1.3050705@cn.fujitsu.com>
References: <cover.1229345769.git.inaky@linux.intel.com>
	<a43305547de5e6c569f584d3d5b863e2def5fb6a.1229345778.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <a43305547de5e6c569f584d3d5b863e2def5fb6a.1229345778.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Inaky Perez-Gonzalez said the following on 2008-12-15 20:58:
> + * @wimax_dev: WiMAX generic device for linkage into the kernel WiMAX
> + *     stack. Due to the way a net_device is allocated, we need to
> + *     force this to be the first field so that we can get from
> + *     net_dev_priv() the right pointer.
> + *

net_dev_priv() -> netdev_priv()

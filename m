From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch netdev-2.6] vlan_dev: return 0 on vlan_dev_change_mtu
 success
Date: Thu, 18 Nov 2004 14:14:08 -0800
Message-ID: <20041118141408.686e7b16.davem@davemloft.net>
References: <20041118140436.A16007@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        netdev@oss.sgi.com, greearb@candelatech.com, vlan@scry.wanfear.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20041118140436.A16007@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004 14:04:36 -0500
"John W. Linville" <linville@tuxdriver.com> wrote:

> The VLAN net driver needs to return 0 from vlan_dev_change_mtu()
> on success.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Both 2.4.x and 2.6.x variants applied, thanks John.

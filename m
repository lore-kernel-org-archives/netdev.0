From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [sparse] rtentry->rt_dev is __user
Date: Tue, 22 Jun 2004 17:09:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622170946.193420fc.davem@redhat.com>
References: <20040622155453.564ede17@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040622155453.564ede17@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2004 15:54:53 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The device entry in the route ioctl's needs annotation.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied.

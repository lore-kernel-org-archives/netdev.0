From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] dynamic net_device for serial eql balancer
Date: Tue, 15 Jul 2003 21:43:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715214332.4a33db6d.davem@redhat.com>
References: <20030715155733.0ee5a14d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030715155733.0ee5a14d.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 15:57:33 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Patch against 2.6.0-test1 to dynamically allocate pseudo network device.
> Compiles and loaded/unloaded but don't have multi-port serial load balancing to test 
> more fuly.

Applied, thanks Stephen.

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: creating a netdevice
Date: Wed, 2 Mar 2005 11:26:22 -0800
Message-ID: <20050302112622.33be433c@dxpl.pdx.osdl.net>
References: <20050302133828.45232.qmail@web26610.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: BZ Benny <bennybbz@yahoo.fr>
In-Reply-To: <20050302133828.45232.qmail@web26610.mail.ukl.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2005 14:38:28 +0100 (CET)
BZ Benny <bennybbz@yahoo.fr> wrote:

> Hi
> 
> I want to create a network interface from the user
> space,
> is it possible?

No, you can't create a network interface from user space.
You probably want to use tun/tap or ethertap device.

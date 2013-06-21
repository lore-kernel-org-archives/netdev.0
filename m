From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: Fwd: Re: [PATCH] can: usb_8dev: unregister netdev before free()ing
Date: Fri, 21 Jun 2013 23:17:25 +0400
Message-ID: <51C4A6C5.7040609@cogentembedded.com>
References: <51C1DC58.2040705@hartkopp.net> <51C4A3B7.9040903@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <51C4A3B7.9040903@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/21/2013 11:04 PM, Oliver Hartkopp wrote:

> can you please integrate this patch into stable 3.9 too?
> The usb_8dev driver was introduced in Linux 3.9 and has now been fixed in
> DaveMs net-tree for 3.10 some days ago.

> Upstream commit 4afe2156eb639e563d6ef0c2706b66ea400348b2

> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=4afe2156eb639e563d6ef0c2706b66ea400348b2

> I wanted to put stable@kernel.org in CC but that bounced.

    Because it's now at stable@vger.kernel.org. You don't need to CC it 
in your mail, just add "Cc: stable@vger.kernel.org" line to the patch 
header after signoff. Though actually, Dave Miller doesn't like this 
protocol and queues the stable patches himself.

> Tnx,
> Oliver

WBR, Sergei


From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: [PATCH] netdev: generate kobject uevent on network state transitions
Date: Tue, 25 Nov 2008 04:08:32 +0100
Message-ID: <ac3eb2510811241908w3d8db29ai7e2ff98d4f8f6edd@mail.gmail.com>
References: <20081121234110.22b47154@extreme>
	 <ac3eb2510811220608y33662b0bkb66026c2a21b061e@mail.gmail.com>
	 <F6B63A37-A69F-4197-B7E5-C9FD9BFA76F6@holtmann.org>
	 <20081122223249.4be03e4e@extreme>
	 <ac3eb2510811230813s3cb5c248k1e15d9ece581c8ad@mail.gmail.com>
	 <20081124114522.1e8de3fe@extreme> <1227557174.3162.7.camel@achroite>
	 <20081124150347.73050f98@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>,
	"Marcel Holtmann" <marcel@holtmann.org>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20081124150347.73050f98@extreme>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2008 at 00:03, Stephen Hemminger <shemminger@vyatta.com> wrote:
> It is easier for some applications to deal with text based interfaces
> like uevent, rather than using netlink to listen for events.
>
> Note, this does not deal with network namespaces but that is a generic
> problem that already exists with kobjects (see rename events).
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Works fine here.

Thanks,
Kay

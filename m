From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to drivers/net
Date: Mon, 21 Jan 2013 23:44:55 +0000
Message-ID: <CANK3SE2p3C38YrvCxWqvoRRz7=q7oAYyE=b0c7+ppBd3yzVrpw@mail.gmail.com>
References: <1358541648-29922-1-git-send-email-mark.einon@gmail.com>
 <20130118225706.GA22140@kroah.com> <20130119110328.GO4584@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org,
	sfr@canb.auug.org.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130119110328.GO4584@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 January 2013 11:03, Dan Carpenter <dan.carpenter@oracle.com> wrote:
<snip>
>
> et131x_get_regs() has endian bugs calling et131x_mii_read().
>
</snip>

Hi Dan,

Could you be a bit more descriptive about the issues you think there
are with these calls?

cheers,

Mark

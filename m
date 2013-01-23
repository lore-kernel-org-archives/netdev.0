From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [RFC PATCH v3 linux-next] et131x: Promote staging et131x driver
 to drivers/net
Date: Wed, 23 Jan 2013 14:51:39 +0000
Message-ID: <CANK3SE1W5O5Df95MpCCWHaQO_tN7OaA1jJ60zrH5Zx66ZGdNiw@mail.gmail.com>
References: <1358935859-29525-1-git-send-email-mark.einon@gmail.com>
 <1358945130-3101-1-git-send-email-mark.einon@gmail.com> <20130123143216.GA2050@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, sfr@canb.auug.org.au,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130123143216.GA2050@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 January 2013 14:32, Greg KH <gregkh@linuxfoundation.org> wrote:
> I usually recommend just creating a new patch, that adds the driver to
> the proper place in the kernel, and sending that in.  If the subsystem
> maintainers accept it, then I can just delete the staging driver.
>
> Yes, this looses the history of the code, but usually no one cares about
> that for staging drivers.
>
> If that's not ok, I have no problem accepting this, if I get an ack from
> the subsystem maintainers that it's ok, but again, this patch makes it
> pretty hard for them to know that or not.

I can see how that works - I'll send a v4 update shorty.

Cheers,

Mark

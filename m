From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 13:19:31 -0700
Message-ID: <20091013201931.GA4622@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013195117.GA3778@kroah.com> <5DDAB7BA7BDB58439DD0EED0B8E9A3AE02E8277A@ausx3mpc102.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, dannf@hp.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Matt_Domsch@Dell.com,
	Charles_Rose@Dell.com
To: Jordan_Hargrave@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE02E8277A@ausx3mpc102.aus.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Tue, Oct 13, 2009 at 03:00:59PM -0500, Jordan_Hargrave@Dell.com wrote:
> We have developed a mapping library that will convert the
> user-friendly symlink names to the kernel names necessary for socket
> ioctls.  All network tools that normally take ethX as argument have
> been modified to use this mapping library.  Usually it's just a
> one-line addition when parsing the command line arguments.

Either I missed this in the first message in this thread, or this was
never stated before, but that is nice.  Where is this library, and will
it be accepted by the upstream tool maintainers?

thanks,

greg k-h

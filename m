From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [BUG] bisected: PandaBoard smsc95xx ethernet driver error from
 USB timeout
Date: Thu, 21 Mar 2013 17:00:52 +0800
Message-ID: <CACVXFVODZNuoLYSk60YwhFhEv5SX2QkszjjoYDWBHij7zwmhdQ@mail.gmail.com>
References: <514A7E81.9000501@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stern@rowland.harvard.edu, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, balbi@ti.com, netdev@vger.kernel.org,
	steve.glendinning@smsc.com
To: frank.rowand@am.sony.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <514A7E81.9000501@am.sony.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Frank,

On Thu, Mar 21, 2013 at 11:29 AM, Frank Rowand <frank.rowand@am.sony.com> wrote:
>
> I found the problem on 3.6.11, but have not replicated it on 3.9-rcX
> yet because my config fails to build on 3.9-rc1 and 3.9-rc2.  I'll try
> to work on that issue tomorrow.

I play upstream kernel on Pandaboard A1 frequently, looks not
see the failure problem before. Maybe the problem is config dependent.

If you may share your config file, I'd like to do the test too.


Thanks,
-- 
Ming Lei

From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] bisected: PandaBoard smsc95xx ethernet driver error from
 USB timeout
Date: Sun, 24 Mar 2013 10:17:36 +0800
Message-ID: <CACVXFVNQV8SAP+oKJWJta0WPhjQO6TreU9U8OjHKtZwa6p6_=A@mail.gmail.com>
References: <514A7E81.9000501@am.sony.com>
	<CACVXFVODZNuoLYSk60YwhFhEv5SX2QkszjjoYDWBHij7zwmhdQ@mail.gmail.com>
	<514B6D77.8080202@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Rowand, Frank" <Frank_Rowand-FuZ7eS5WsvxBDgjK7y7TUQ@public.gmane.org>,
	"stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"balbi-l0cyMroinI0@public.gmane.org" <balbi-l0cyMroinI0@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"steve.glendinning-sdUf+H5yV5I@public.gmane.org" <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
To: frank.rowand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <514B6D77.8080202-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 22, 2013 at 4:28 AM, Frank Rowand <frank.rowand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org> wrote:
>> I play upstream kernel on Pandaboard A1 frequently, looks not
>> see the failure problem before. Maybe the problem is config dependent.
>>
>> If you may share your config file, I'd like to do the test too.

3.9-rc2-20130314 doesn't have the problem observed on my Pandaboard A1,
but I only tested booting from MMC, not from NFS.


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

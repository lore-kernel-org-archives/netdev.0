From: James Morris <jmorris@redhat.com>
Subject: Re: Netlink Connector / CBUS
Date: Tue, 5 Apr 2005 01:10:06 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0504050108260.9383-100000@thoron.boston.redhat.com>
References: <Xine.LNX.4.44.0504050030230.9273-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, <rml@novell.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <Xine.LNX.4.44.0504050030230.9273-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2005, James Morris wrote:

> A few questions:

Also, please allow cn_add_callback() allow it to be passed a NULL 
callback function, so the caller doesn't pass in a dummy function and your 
code doesn't waste time dealing with something which isn't real.


- James
-- 
James Morris
<jmorris@redhat.com>

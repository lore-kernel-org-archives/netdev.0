From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Gratuitous ARP
Date: Thu, 4 Dec 2003 13:24:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB0D41ED0.73C9674E-ON88256DF2.0074D58D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Hi,

I am trying to find out why gratuitous ARP isn't implemented for IPv4
duplicate address detection, though a comment is present in the
arp.c that it was added. Was it removed for any reason ? I went
through netdev archives and found some threads relating to this, but
no comments were there on why this feature is absent or removed.
Could it be to avoid a flood arp attack ? If so, any reason why it cannot
be implemented under a configuration param ?

I would appreciate if someone can throw any light on this.

Thanks,

- KK

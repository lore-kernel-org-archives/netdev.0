From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] bug in ARP override timer near jiffies wrap
Date: Fri, 7 May 2004 14:51:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFCBE52D62.180AE438-ON88256E8D.0077E81B-88256E8D.00780545@us.ibm.com>
References: <20040507144000.7a57d76a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040507144000.7a57d76a.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote on 05/07/2004 02:40:00 PM:

> David, do you realize that the existing formula is not only
> correct, but also covers a greater time space than the
> time_*() mechanisms do?

ARG! you're right, of course-- I noticed only that they are
different and didn't think about it actually be right! :-)

                                +-DLS

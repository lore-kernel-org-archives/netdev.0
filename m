From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 12:49:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F118DB7.5060009@pobox.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>	 <20030713004818.4f1895be.davem@redhat.com>  <52u19qwg53.fsf@topspin.com> <1058113895.554.7.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, "David S. Miller" <davem@redhat.com>,
   Alan Shih <alan@storlinksemi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1058113895.554.7.camel@dhcp22.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> Finally if you are streaming objects by non mapped references (eg
> sendfile or see LM's paper from long ago on splice()) then the problem
> goes away.


I had forgotten all about splice.

For interested readers, here is the link:
http://www.bitmover.com/lm/papers/splice.ps

	Jeff

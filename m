From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 2.6.x Tulip oops while doing eject/rmmod on live interface
Date: Sun, 25 Apr 2004 21:40:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408C687B.2000907@pobox.com>
References: <m3hdv7o79a.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3hdv7o79a.fsf@defiant.pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Hi,
> 
> The attached patch fixes an "oops" in tulip driver when a live interface
> is deactivated (i.e. PC Card ejected or module unloaded) without being
> brought down first.
> 
> Please apply to Linux 2.6. Thanks.


hmmm, yeah, looks like a bug.  Thanks,

	Jeff

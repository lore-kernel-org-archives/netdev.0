From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: NAPI interrupt data
Date: Sat, 15 Feb 2003 02:24:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E4DEB47.1070909@pobox.com>
References: <3E4DE95C.2050804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
In-Reply-To: <3E4DE95C.2050804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> "approximate packets per second":
> 
> bash-2.05b$ ./x.pl data.crumb
> 135 samples, 21578 avg
> bash-2.05b$ ./x.pl data.hum
> 130 samples, 11213 avg


er.  I meant _interrupts_ per second.

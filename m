From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [PATCH] 2.4.20-pre sundance.c cleanups
Date: Thu, 19 Sep 2002 17:11:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6067.1032419500@kao2.melbourne.sgi.com>
References: <200209190642.g8J6gxX29989@vindaloo.ras.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@sgi.com
In-reply-to: Your message of "Thu, 19 Sep 2002 00:42:59 CST."
             <200209190642.g8J6gxX29989@vindaloo.ras.ucalgary.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Sep 2002 00:42:59 -0600, 
Richard Gooch <rgooch@ras.ucalgary.ca> wrote:
>Speaking of forcing speeds, is the following in /etc/modules.conf
>supposed to work? Did I get the syntax right?
>  options         sundance        media="autosense","100mbps_fd","autosense"

man modules.conf, look for special.
  media='"autosense,100mbps_fd,autosense"'
should work.

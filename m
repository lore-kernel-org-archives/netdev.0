From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [Fwd: [Bug 3397] New: Network connections hang going through
 an OpenBSD firewall]
Date: Tue, 14 Sep 2004 14:21:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414760E5.4010703@us.ibm.com>
References: <41475BEA.2030803@us.ibm.com> <41475E1E.7010200@veus.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir <vlists@veus.hr>
In-Reply-To: <41475E1E.7010200@veus.hr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vladimir wrote:

> It doesn't work with it. Should I download 2.6.8-1 from kernel.org and 
> compile it by hand ?

If you can, download the latest (linux-2.6.9-rc2). You can
get the patch against linux-2.6.8.1 vanilla from
kernel.org.

> It is certainly possible but everything works fine with all other OSes 
> and kernels 2.6.5 and below which leads me to believe something was 
> changed in 2.6.6 that broke it.
> 
> Are you able to reproduce it ?

Unfortunately, I have zero cycles right now (and in the near
future) to address any issues, I'm afraid. Someone on netdev
will likely be able to help you or have run into it already.
See Stephen's post from a few minutes ago..

thanks,
Nivedita

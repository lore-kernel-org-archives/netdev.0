From: Vladimir <vlists@veus.hr>
Subject: Re: [Fwd: [Bug 3397] New: Network connections hang going through
 an OpenBSD firewall]
Date: Tue, 14 Sep 2004 15:09:50 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41475E1E.7010200@veus.hr>
References: <41475BEA.2030803@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <41475BEA.2030803@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:

> Can you reproduce on the latest kernel, please?

I will try it with the latest kernel. I have tried this with kernel 
2.6.8-1.521 from

http://www.atrpms.net/dist/

It doesn't work with it. Should I download 2.6.8-1 from kernel.org and 
compile it by hand ?

> Is the OpenBSD mangling the packet in any way?


It is certainly possible but everything works fine with all other OSes 
and kernels 2.6.5 and below which leads me to believe something was 
changed in 2.6.6 that broke it.

Are you able to reproduce it ?

Thanks,

Vladimir Vuksan

> Can anyone tell me if this smells like something
> recently fixed (MTU issues)? Doesn't sound like
> the windowscaling problem but could be related.



> http://bugme.osdl.org/show_bug.cgi?id=3397

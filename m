From: Eng Se-Hsieng <g0202512@nus.edu.sg>
Subject: Re: SIOCGIFCONF and ifr_bandwidth
Date: 30 Jun 2003 21:34:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057037686.1564.19.camel@nusnet-165-146.dynip.nus.edu.sg>
References: <1057037447.1564.14.camel@nusnet-165-146.dynip.nus.edu.sg>
	<1057037598.1597.16.camel@nusnet-165-146.dynip.nus.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1057037598.1597.16.camel@nusnet-165-146.dynip.nus.edu.sg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Dear all,
>  
> Could someone please tell me why when I use 
>  
> ioctl(fd, SIOCGIFCONF, (char *)cf);
> 
> All the addresses returned have a link bandwidth
> (ifrequest->ifr_bandwidth) of 2?
>  
> What does this 2 mean and why is the same for all the interfaces (eth,
> ppp, lo)?
> 
> Thank you.
>  
> Regards,
>  
> Se-Hsieng
>  
> 
> 
> 

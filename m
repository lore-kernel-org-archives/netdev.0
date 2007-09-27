From: Alan Menegotto <macnish@gmail.com>
Subject: Re: Linux networking implementation and packet capture
Date: Thu, 27 Sep 2007 07:48:37 -0300
Message-ID: <46FB8A85.2080003@gmail.com>
References: <1a41e0840709262347m1fc5d99dge9aeb172b7fc610e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernelnewbies@nl.linux.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Gaurav Aggarwal <grv.aggarwal@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1a41e0840709262347m1fc5d99dge9aeb172b7fc610e@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gaurav Aggarwal escreveu:
> Hi,
>
> I am trying to understand the implementation of linux 2.4 and linux 
> 2.6's networking (IPV4) . Can anyone give me some idea/pointers about 
> some of the good resources/whitepapers available in the market to 
> understand the same. If there is any document that mention the changes 
> between the implementation of networking in 2.4 & 2.6
>
> I am also trying to write a simple program(preferably a userspace 
> application) which captures all the incoming and outgoing packets of a 
> particular machine (preferably at PREROUTING stage), then according to 
> the SRC/DST addresses, changes the IP address of some of the packets 
> and then reinject it back into the local IP stack. I am able to do 
> that in 2.4 kernel by using libipq and ip_tables but that prog is not 
> running in 2.6 kernel. (It hits at ip_route_BUG). Any idea or code 
> snippet will be really appreciated.
>
> -- 
> Regards,
> Gaurav Aggarwal
>
You may also see the information on the linux-net wiki: 
http://linux-net.osdl.org/index.php/Main_Page.

Also, read some threads on netdev list. It has a lot of information 
there too.





-- 


--
Best Regards

Alan Menegotto


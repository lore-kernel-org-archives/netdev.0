From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [PATCH] ipw2100 v1.1.0
Date: Fri, 25 Mar 2005 12:35:18 -0600
Message-ID: <424459E6.4020701@linux.intel.com>
References: <20050324185959.GA22129@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: jt@hpl.hp.com
In-Reply-To: <20050324185959.GA22129@bougret.hpl.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:

>James Ketrenos wrote :
>  
>
>>I wasn't sure where to actually stick the driver's selection it in the 
>>Kconfig menu.  Where its at now, it doesn't show up until you enable 
>>'Generic IEEE 80211 subsystem', and then it shows up down under Wireless 
>>Lan entries.
>>    
>>
>
>	I personally enable the driver to be selected directly and
>then SELECT the 802.11 stack, the same way you SELECT the firmware
>loader. The logic is that the user doesn't really care how it's
>implemented under the cover (via the 802.11 stack or not), he just
>want to make his hardware work. A good example of this logic is the
>Aironet driver (PCI versus Pcmcia).
>  
>
Good idea; I took that approach for the ipw2200 submission (just sent).

>	But, those are trivial matter that can be discussed and
>resolved long after the driver is in the kernel, so no need to respin
>your patch. Anyway, most people use distro kernels that have all
>options enabled...
>
>	Apart from that, congratulation on the excellent work...
>  
>
Thanks,
James

>	Have fun...
>
>	Jean
>
>  
>

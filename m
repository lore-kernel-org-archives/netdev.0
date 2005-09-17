From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: Ethernet interface problem -- system lockup.
Date: Sat, 17 Sep 2005 15:06:42 +0200
Message-ID: <432C14E2.10001@gmail.com>
References: <40b4372005091616024e4dd9a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751104AbVIQNGt@vger.kernel.org>
To: simon.d.matthews@gmail.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
In-Reply-To: <40b4372005091616024e4dd9a3@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Matthews napsal(a):

>The machine became unresponsive immediately after this. It would not
>respond to either the network, or keyboard.
>
>It is running a RedHat kernel 2.4.20 or similar. 
>  
>
2.4.31 update?

>Sep 15 16:20:28 xxxx kernel: eth1: Error -- Rx packet size(8172) > mtu(1500)+14
>Sep 15 16:20:28 xxxx kernel: eth1: Error -- Rx packet size(8172) > mtu(1500)+14
>Sep 15 16:20:28 xxxx last message repeated 9 times
>Sep 15 16:20:28 xxxx kernel: eth1: Error -- Rx packet size(4391) > mtu(1500)+14
>Sep 15 16:21:19 xxxx last message repeated 8 times
>Sep 15 16:21:19 xxxx kernel: eth1: Rx ERROR!!!
>Sep 15 16:21:20 xxxx last message repeated 31 times
>Sep 15 16:21:20 xxxx kernel: !!!
>Sep 15 16:21:20 xxxx kernel: !!!
>Sep 15 16:21:20 xxxx kernel: eth1: Rx ERR!!!
>Sep 15 16:21:20 xxxx kernel: eth1: Rx ERR!!!
>Sep 15 16:21:20 xxxx kernel: eth1: Rx ERRO!!!
>Sep 15 16:21:20 xxxx kernel: eth1: Rx ERRO!!!
>Sep 15 16:21:20 xxxx kernel: eth1: Rx ERR!!!
>  
>
Is it possible to tell kernel to be more debug (and syslog)?
Which drivers? Which hardware? .config
Some more info needed.

Maybe netdev is beeter mailing list for this.

thanks,

-- 
Jiri Slaby         www.fi.muni.cz/~xslaby
~\-/~      jirislaby@gmail.com      ~\-/~
241B347EC88228DE51EE A49C4A73A25004CB2A10

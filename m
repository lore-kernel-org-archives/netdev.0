From: Cedric Gavage <cedric.gavage@unixtech.be>
Subject: Re: [Fwd: kernel 2.4.21]
Date: Wed, 23 Jul 2003 13:40:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E7435.4060308@unixtech.be>
References: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk>	<20030719191723.0821227f.davem@redhat.com>	<3F1E53F7.5000803@unixtech.be>	<20030723023528.76b0f69c.davem@redhat.com>	<3F1E58EE.5010109@unixtech.be> <20030723024648.2e4b6a62.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030723024648.2e4b6a62.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 23 Jul 2003 11:44:14 +0200
> Cedric Gavage <cedric.gavage@unixtech.be> wrote:
> 
> 
>>David S. Miller wrote:
>>
>>>On Wed, 23 Jul 2003 11:23:03 +0200
>>>Cedric Gavage <cedric.gavage@unixtech.be> wrote:
>>>
>>>>Still this with 2.4.21 kernel: (intel internet card, driver eepro100)
>>>>
>>>>Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
>>>>Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed at tcp.c(1563)
>>>
>>>Are you running and old version of vsftpd?
>>
>>Thanks for your help...
>>
>>This server is efnet.skynet.be, ircd server connected on EFnet with 
>>ircd-hybrid-6.4...
> 
> 
> Any chance you can try with the e100 driver instead of eepro100?
> 
Ok, now it's e100 driver, I will wait some hours to see if we have again 
problems, thanks for your help.

-- 
  Cedric Gavage <cedric.gavage@unixtech.be>
  http://unixtech.be - http://gavage.com - OpenPGP: 0xED325C64

From: Roberto Medina <robertoxmed@gmail.com>
Subject: Re: [PATCH] net: eth: realtek: atp: checkpatch errors and warnings
 corrected
Date: Wed, 05 Nov 2014 08:44:54 +0100
Message-ID: <5459D576.3010000@gmail.com>
References: <1415039073-20164-1-git-send-email-robertoxmed@gmail.com> <1415040686.17743.31.camel@perches.com> <5457D2DF.5000508@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1C9E71E4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E71E4@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/04/2014 11:19 AM, David Laight wrote:
>
> That code (and all the ones below) are gibberish, neither the old or new
> sequences make any sense.
>

Thank you for your feedback I did it again and objdiff doesn't show any 
changes (if I'm not mistaken).

> Almost as though you used the wrong instruction set!
>
> 	David

diff -Nurd 
/home/vov/Git/linux-next/.tmp_objdiff/a641d0e/drivers/net/ethernet/realtek/atp.dis 
/home/vov/Git/linux-next/.tmp_objdiff/5f19b70/drivers/net/ethernet/realtek/atp.dis
--- 
/home/vov/Git/linux-next/.tmp_objdiff/a641d0e/drivers/net/ethernet/realtek/atp.dis 
2014-11-05 08:38:49.244100507 +0100
+++ 
/home/vov/Git/linux-next/.tmp_objdiff/5f19b70/drivers/net/ethernet/realtek/atp.dis 
2014-11-05 08:39:14.654101606 +0100
@@ -1357,7 +1357,7 @@

  Disassembly of section .bss:

-00000000 <num_tx_since_rx.36127>:
+00000000 <num_tx_since_rx.36172>:
  :	00 00                	add    %al,(%eax)
  	...

Thanks,

Roberto

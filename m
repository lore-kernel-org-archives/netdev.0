From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: High CPU utilization with Bonding driver ?
Date: Tue, 05 Apr 2005 13:31:26 -0700
Message-ID: <200504052031.j35KVQiR027629@death.nxdomain.ibm.com>
References: <ravinandan.arakali@neterion.com>
Cc: "'Arthur Kepner'" <akepner@sgi.com>, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net,
        "'Leonid. Grossman (E-mail)'" <leonid.grossman@neterion.com>,
        "'Raghavendra. Koushik (E-mail)'" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
In-Reply-To: Message from "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
   of "Tue, 05 Apr 2005 12:04:56 PDT." <002a01c53a12$5b876770$3a10100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ravinandan Arakali <ravinandan.arakali@neterion.com> wrote:

>The problem does not seem to be due to your patch because
>the bonding driver built without your patch crashes too on load.
>However, the pre-existing binary under /lib/modules/`uname -r`/...
>works fine.
>Any idea why this may be happening ?
>
>Given below is the output of trying to insmod the bonding driver.
>
>linux:/usr/src/linux-2.6.5-7.135/drivers/net/bonding # insmod bonding.ko
>mode=4 miimon=100

	What's this kernel from, and do you have the config file
available?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

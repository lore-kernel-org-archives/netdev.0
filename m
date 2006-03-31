From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 14:51:15 +0400
Message-ID: <442D09A3.3020700@kernelpanic.ru>
References: <20060331.011245.26474207.davem@davemloft.net>	<442D0186.8090705@kernelpanic.ru>	<20060331103956.GA12181@gondor.apana.org.au> <20060331.024544.96296223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060331.024544.96296223.davem@davemloft.net>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Hello, David S. Miller.

On 31.03.2006 14:45 you said the following:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 31 Mar 2006 21:39:56 +1100
> 
> 
>>Anyway, it didn't take long to find another bug in the same area.
>>I'm afraid this driver does seem to be full of them :)
> 
> 
> Indeed.
> 
> Thanks for picking through this some more Herbert.  I hope we got it
> this time.


Recompiling the kernel. I need about 2 hours to get the answer...

-- 
Boris B. Zhmurov
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
